import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/contacts/domain/entities/emergency_contact.dart';
import '../../features/contacts/presentation/cubit/contacts_cubit.dart';
import '../../features/contacts/presentation/cubit/contacts_state.dart';
import '../../features/contacts/presentation/widgets/contact_tile.dart';
import '../router/app_router.dart';

/// Emergency contacts list screen.
///
/// Displays the authenticated user's emergency contacts with add / edit /
/// delete / set-primary actions. All data flows through [ContactsCubit],
/// which delegates to the contacts repository.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContactsCubit>().loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.emergencyContacts)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addContact),
        tooltip: AppStrings.addContact,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<ContactsCubit, ContactsState>(
        listener: _handleState,
        builder: (context, state) {
          if (state.status == ContactsStatus.loading &&
              state.contacts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ContactsStatus.failure &&
              state.contacts.isEmpty) {
            return _ContactsErrorState(
              onRetry: () => context.read<ContactsCubit>().loadContacts(),
            );
          }
          if (state.contacts.isEmpty) {
            return _ContactsEmptyState(
              onAdd: () => context.push(AppRoutes.addContact),
            );
          }
          return _ContactsList(contacts: state.contacts);
        },
      ),
    );
  }

  void _handleState(BuildContext context, ContactsState state) {
    if (state.status == ContactsStatus.failure && state.message != null) {
      Helpers.showErrorSnackBar(context, state.message!);
    } else if (state.status == ContactsStatus.success &&
        state.message != null) {
      Helpers.showSuccessSnackBar(context, state.message!);
      context.read<ContactsCubit>().resetStatus();
    }
  }
}
/// Scrollable list of contact cards, primary contact first.
class _ContactsList extends StatelessWidget {
  const _ContactsList({required this.contacts});

  final List<EmergencyContact> contacts;

  @override
  Widget build(BuildContext context) {
    final sorted = [...contacts]..sort((a, b) {
        if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

    return RefreshIndicator(
      onRefresh: () => context.read<ContactsCubit>().loadContacts(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSM),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final contact = sorted[index];
          return ContactTile(
            contact: contact,
            onEdit: () => context.push(AppRoutes.addContact, extra: contact),
            onDelete: () => _confirmDelete(context, contact),
            onSetPrimary: () =>
                context.read<ContactsCubit>().setPrimaryContact(contact.id),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: AppStrings.deleteContactConfirmTitle,
      message: AppStrings.deleteContactConfirmMessage,
      confirmText: AppStrings.deleteContact,
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      context.read<ContactsCubit>().deleteContact(contact.id);
    }
  }
}
/// Empty state shown when the user has no emergency contacts yet.
class _ContactsEmptyState extends StatelessWidget {
  const _ContactsEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: const BoxDecoration(
                color: AppColors.skyBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_share,
                size: AppDimensions.iconXL,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text(
              AppStrings.noContacts,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            Text(
              AppStrings.noContactsDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            CustomButton(
              label: AppStrings.addContact,
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state shown when contacts could not be loaded.
class _ContactsErrorState extends StatelessWidget {
  const _ContactsErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.iconXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text(
              AppStrings.somethingWentWrong,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            CustomButton(
              label: AppStrings.retry,
              icon: Icons.refresh,
              variant: ButtonVariant.secondary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
