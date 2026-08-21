import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/medicine_reminder_service.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../features/medicine/domain/entities/medicine.dart';
import '../../features/medicine/presentation/cubit/medicines_cubit.dart';
import '../../features/medicine/presentation/cubit/medicines_state.dart';

/// Add / edit a medicine.
///
/// When navigated to with a [Medicine] passed as the go_router `extra`, the
/// form pre-fills and saves via [MedicinesCubit.updateMedicine]; otherwise it
/// creates a new medicine via [MedicinesCubit.addMedicine].
///
/// Dosage and instructions are user/doctor-entered data only. This app never
/// invents dosages or prescribes medication.
class EditMedicineScreen extends StatefulWidget {
  const EditMedicineScreen({super.key});

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _prescribedByController;
  late final TextEditingController _notesController;
  final List<TimeOfDayValue> _reminderTimes = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isSaving = false;
  bool _initialized = false;

  Medicine? _medicine;

  bool get _isEditing => _medicine != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _medicine = GoRouterState.of(context).extra as Medicine?;
    _nameController = TextEditingController(text: _medicine?.name ?? '');
    _dosageController = TextEditingController(text: _medicine?.dosage ?? '');
    _frequencyController = TextEditingController(
      text: _medicine?.frequency ?? '',
    );
    _prescribedByController = TextEditingController(
      text: _medicine?.prescribedBy ?? '',
    );
    _notesController = TextEditingController(text: _medicine?.notes ?? '');
    _reminderTimes.addAll(_medicine?.reminderTimes ?? const []);
    _startDate = _medicine?.startDate;
    _endDate = _medicine?.endDate;
    _isActive = _medicine?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _prescribedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickReminderTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      setState(() {
        _reminderTimes.add(
          TimeOfDayValue(hour: picked.hour, minute: picked.minute),
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final medicine = Medicine(
      id: _medicine?.id ?? '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      reminderTimes: List<TimeOfDayValue>.from(_reminderTimes),
      startDate: _startDate,
      endDate: _endDate,
      prescribedBy: _prescribedByController.text.trim(),
      notes: _notesController.text.trim(),
      isActive: _isActive,
      createdAt: _medicine?.createdAt,
      updatedAt: DateTime.now(),
    );

    final cubit = context.read<MedicinesCubit>();
    if (_isEditing) {
      cubit.updateMedicine(medicine);
    } else {
      cubit.addMedicine(medicine);
    }

    // Schedule (or cancel) local reminders for this medicine.
    final reminderService = context.read<MedicineReminderService>();
    await reminderService.scheduleMedicineReminders(medicine);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editMedicine : AppStrings.addMedicine),
      ),
      body: BlocListener<MedicinesCubit, MedicinesState>(
        listener: (context, state) {
          if (state.status == MedicinesStatus.success) {
            context.pop();
          } else if (state.status == MedicinesStatus.failure &&
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
                CustomTextField(
                  controller: _nameController,
                  label: AppStrings.medicineName,
                  hint: 'e.g. Metformin',
                  prefixIcon: const Icon(Icons.medication_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                CustomTextField(
                  controller: _dosageController,
                  label: AppStrings.dosage,
                  hint: AppStrings.dosageHint,
                  prefixIcon: const Icon(Icons.speed_outlined),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                CustomTextField(
                  controller: _frequencyController,
                  label: AppStrings.frequency,
                  hint: AppStrings.frequencyHint,
                  prefixIcon: const Icon(Icons.repeat_outlined),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildReminderTimes(),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildDates(),
                const SizedBox(height: AppDimensions.paddingMD),
                CustomTextField(
                  controller: _prescribedByController,
                  label: AppStrings.prescribedBy,
                  hint: AppStrings.prescribedByHint,
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                CustomTextField(
                  controller: _notesController,
                  label: AppStrings.medicineNotes,
                  hint: AppStrings.medicineNotesHint,
                  prefixIcon: const Icon(Icons.notes_outlined),
                  maxLines: 3,
                  minLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildActiveSwitch(),
                const SizedBox(height: AppDimensions.paddingMD),
                Text(
                  AppStrings.medicineReminderSafetyNote,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingLG),
                CustomButton(
                  label: AppStrings.saveMedicine,
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

  Widget _buildReminderTimes() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.alarm_outlined,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                Text(
                  AppStrings.reminderTimes,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            if (_reminderTimes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingSM,
                ),
                child: Text(
                  AppStrings.noReminderTimes,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ..._reminderTimes.asMap().entries.map(
                (entry) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule, size: 20),
                  title: Text(Helpers.formatTimeFromParts(
                    entry.value.hour,
                    entry.value.minute,
                  )),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(
                      () => _reminderTimes.removeAt(entry.key),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppDimensions.paddingSM),
            OutlinedButton.icon(
              onPressed: _pickReminderTime,
              icon: const Icon(Icons.add_alarm),
              label: const Text(AppStrings.addReminderTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDates() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: AppStrings.startDate,
            hint: _startDate == null
                ? 'Select'
                : Helpers.formatDate(_startDate!),
            readOnly: true,
            prefixIcon: const Icon(Icons.event_outlined),
            onTap: _pickStartDate,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        Expanded(
          child: CustomTextField(
            label: AppStrings.optionalEndDate,
            hint: _endDate == null ? 'None' : Helpers.formatDate(_endDate!),
            readOnly: true,
            prefixIcon: const Icon(Icons.event_available_outlined),
            onTap: _pickEndDate,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        value: _isActive,
        onChanged: (value) => setState(() => _isActive = value),
        title: const Text(AppStrings.activeMedicine),
        subtitle: Text(
          _isActive ? AppStrings.remindersScheduled : AppStrings.remindersCancelled,
        ),
        secondary: const Icon(Icons.notifications_active_outlined),
      ),
    );
  }
}
