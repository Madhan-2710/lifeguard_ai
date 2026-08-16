import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../features/contacts/domain/entities/emergency_contact.dart';
import '../../features/contacts/presentation/cubit/contacts_cubit.dart';
import '../../features/contacts/presentation/cubit/contacts_state.dart';

/// Add / edit emergency contact form.
///
/// When navigated to with an [EmergencyContact] passed as the go_router
/// `extra`, the form pre-fills and saves via [ContactsCubit.updateContact];
/// otherwise it creates a new contact via [ContactsCubit.addContact].
class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  static const List<String> _relationshipOptions = [
    AppStrings.relationshipSpouse,
    AppStrings.relationshipParent,
    AppStrings.relationshipChild,
    AppStrings.relationshipSibling,
    AppStrings.relationshipFriend,
    AppStrings.relationshipDoctor,
    AppStrings.relationshipOther,
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late String _relationship;
  late bool _isPrimary;
  bool _isSaving = false;
  bool _initialized = false;

  EmergencyContact? _contact;

  bool get _isEditing => _contact != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // GoRouterState.of uses dependOnInheritedWidgetOfExactType, which is not
    // allowed in initState, so the route extra is read here instead.
    if (_initialized) return;
    _initialized = true;
    _contact = GoRouterState.of(context).extra as EmergencyContact?;
    _nameController = TextEditingController(text: _contact?.name ?? '');
    _phoneController = TextEditingController(text: _contact?.phoneNumber ?? '');
    _relationship = _contact?.relationship ?? AppStrings.relationshipOther;
    _isPrimary = _contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final contact = EmergencyContact(
      id: _contact?.id ?? '',
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      relationship: _relationship,
      isPrimary: _isPrimary,
      createdAt: _contact?.createdAt,
      updatedAt: DateTime.now(),
    );

    final cubit = context.read<ContactsCubit>();
    if (_isEditing) {
      cubit.updateContact(contact);
    } else {
      cubit.addContact(contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editContact : AppStrings.addContact),
      ),
      body: BlocListener<ContactsCubit, ContactsState>(
        listener: (context, state) {
          if (state.status == ContactsStatus.success) {
            context.pop();
          } else if (state.status == ContactsStatus.failure &&
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
                  label: AppStrings.contactName,
                  hint: 'e.g. John Doe',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: Validators.validateContactName,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                CustomTextField(
                  controller: _phoneController,
                  label: AppStrings.contactPhone,
                  hint: 'e.g. +1 555 123 4567',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  validator: Validators.validateContactPhone,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildRelationshipField(),
                const SizedBox(height: AppDimensions.paddingMD),
                _buildPrimarySwitch(),
                const SizedBox(height: AppDimensions.paddingLG),
                CustomButton(
                  label: AppStrings.saveContact,
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

  Widget _buildRelationshipField() {
    return DropdownButtonFormField<String>(
      initialValue: _relationship,
      decoration: const InputDecoration(
        labelText: AppStrings.relationship,
        prefixIcon: Icon(Icons.family_restroom),
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
      items: _relationshipOptions
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _relationship = value);
        }
      },
    );
  }

  Widget _buildPrimarySwitch() {
    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        value: _isPrimary,
        onChanged: (value) => setState(() => _isPrimary = value),
        title: const Text(AppStrings.setAsPrimary),
        subtitle: const Text(AppStrings.primaryContactDescription),
        secondary: const Icon(Icons.star_outline, color: AppColors.primaryBlue),
      ),
    );
  }
}
