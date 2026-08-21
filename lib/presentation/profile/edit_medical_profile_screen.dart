import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../features/medical_profile/domain/entities/medical_profile.dart';
import '../../features/medical_profile/presentation/cubit/medical_profile_cubit.dart';
import '../../features/medical_profile/presentation/cubit/medical_profile_state.dart';

/// Edit the authenticated user's medical profile.
///
/// All fields are user/doctor-entered data. The app never invents dosages,
/// diagnoses, or prescriptions.
class EditMedicalProfileScreen extends StatefulWidget {
  const EditMedicalProfileScreen({super.key});

  @override
  State<EditMedicalProfileScreen> createState() =>
      _EditMedicalProfileScreenState();
}

class _EditMedicalProfileScreenState extends State<EditMedicalProfileScreen> {
  static const List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  final _formKey = GlobalKey<FormState>();
  DateTime? _dateOfBirth;
  String _bloodGroup = '';
  final List<String> _allergies = [];
  final List<String> _chronicConditions = [];
  final List<String> _currentMedicines = [];
  final List<String> _pastSurgeries = [];
  final _notesController = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final profile = context.read<MedicalProfileCubit>().state.profile;
    _dateOfBirth = profile.dateOfBirth;
    _bloodGroup = profile.bloodGroup;
    _allergies.addAll(profile.allergies);
    _chronicConditions.addAll(profile.chronicConditions);
    _currentMedicines.addAll(profile.currentMedicines);
    _pastSurgeries.addAll(profile.pastSurgeries);
    _notesController.text = profile.emergencyMedicalNotes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final profile = MedicalProfile(
      dateOfBirth: _dateOfBirth,
      bloodGroup: _bloodGroup,
      allergies: _allergies,
      chronicConditions: _chronicConditions,
      currentMedicines: _currentMedicines,
      pastSurgeries: _pastSurgeries,
      emergencyMedicalNotes: _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    context.read<MedicalProfileCubit>().saveProfile(profile);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 30, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editMedicalProfile)),
      body: BlocListener<MedicalProfileCubit, MedicalProfileState>(
        listener: (context, state) {
          if (state.status == MedicalProfileStatus.success) {
            context.pop();
          } else if (state.status == MedicalProfileStatus.failure &&
              state.message != null) {
            if (mounted) setState(() => _isSaving = false);
            Helpers.showErrorSnackBar(context, state.message!);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDateOfBirthField(),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildBloodGroupField(),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildListEditor(
                  title: AppStrings.allergies,
                  icon: Icons.warning_amber_outlined,
                  items: _allergies,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildListEditor(
                  title: AppStrings.chronicConditions,
                  icon: Icons.medical_information_outlined,
                  items: _chronicConditions,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildListEditor(
                  title: AppStrings.currentMedicines,
                  icon: Icons.medication_outlined,
                  items: _currentMedicines,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildListEditor(
                  title: AppStrings.pastSurgeries,
                  icon: Icons.healing_outlined,
                  items: _pastSurgeries,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                CustomTextField(
                  controller: _notesController,
                  label: AppStrings.emergencyMedicalNotes,
                  hint: AppStrings.emergencyMedicalNotesHint,
                  prefixIcon: const Icon(Icons.notes_outlined),
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                Text(
                  AppStrings.medicalProfileSafetyNote,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingLG),
                CustomButton(
                  label: AppStrings.saveChanges,
                  icon: Icons.check,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return CustomTextField(
      label: AppStrings.dateOfBirth,
      hint: _dateOfBirth == null
          ? 'Select date'
          : Helpers.formatDate(_dateOfBirth!),
      readOnly: true,
      prefixIcon: const Icon(Icons.cake_outlined),
      suffixIcon: const Icon(Icons.calendar_today_outlined),
      onTap: _pickDateOfBirth,
    );
  }

  Widget _buildBloodGroupField() {
    return DropdownButtonFormField<String>(
      initialValue: _bloodGroup.isEmpty ? null : _bloodGroup,
      decoration: const InputDecoration(
        labelText: AppStrings.bloodGroup,
        prefixIcon: Icon(Icons.bloodtype_outlined),
        filled: true,
        fillColor: AppColors.offWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusLG)),
          borderSide: BorderSide(color: AppColors.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusLG)),
          borderSide: BorderSide(color: AppColors.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusLG)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      hint: const Text('Select blood group'),
      items: _bloodGroups
          .map(
            (group) => DropdownMenuItem(
              value: group,
              child: Text(group),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _bloodGroup = value);
      },
    );
  }

  Widget _buildListEditor({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: AppDimensions.paddingSM),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingSM,
                ),
                child: Text(
                  AppStrings.noItems,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...items.map(
                (item) => Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => items.remove(item)),
                ),
              ),
            const SizedBox(height: AppDimensions.paddingSM),
            _ItemAdder(
              hint: AppStrings.itemHint,
              onAdd: (value) {
                setState(() => items.add(value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemAdder extends StatefulWidget {
  const _ItemAdder({required this.hint, required this.onAdd});

  final String hint;
  final ValueChanged<String> onAdd;

  @override
  State<_ItemAdder> createState() => _ItemAdderState();
}

class _ItemAdderState extends State<_ItemAdder> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onAdd(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _controller,
            hint: widget.hint,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        IconButton.filled(
          onPressed: _submit,
          icon: const Icon(Icons.add),
          tooltip: AppStrings.addItem,
        ),
      ],
    );
  }
}
