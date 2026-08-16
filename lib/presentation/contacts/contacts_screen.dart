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
          return _ContactCard(
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
/// A single contact card with edit / delete / set-primary actions.
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  final EmergencyContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  @override
  Widget build(BuildContext context) {
    final avatarColor = Helpers.generateColorFromString(contact.name);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingXS,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: avatarColor.withValues(alpha: 0.15),
          child: Text(
            Helpers.getInitials(contact.name),
            style: TextStyle(
              color: avatarColor,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontMD,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (contact.isPrimary) ...[
              const SizedBox(width: AppDimensions.paddingSM),
              const _PrimaryBadge(),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppDimensions.paddingXS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContactInfoRow(
                icon: Icons.phone_outlined,
                text: contact.phoneNumber,
              ),
              const SizedBox(height: AppDimensions.paddingXXS),
              _ContactInfoRow(
                icon: Icons.person_outline,
                text: contact.relationship,
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: AppStrings.editContact,
          onSelected: (value) {
            if (value == 'primary') {
              onSetPrimary();
            } else if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            if (!contact.isPrimary)
              const PopupMenuItem(
                value: 'primary',
                child: Text(AppStrings.setAsPrimary),
              ),
            const PopupMenuItem(
              value: 'edit',
              child: Text(AppStrings.editContact),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(AppStrings.deleteContact),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small icon + text row used inside a contact card.
class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.paddingXS),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: AppDimensions.fontSM,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Badge shown next to the primary emergency contact.
class _PrimaryBadge extends StatelessWidget {
  const _PrimaryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: AppColors.primaryBlue),
          SizedBox(width: 4),
          Text(
            AppStrings.primaryContact,
            style: TextStyle(
              fontSize: AppDimensions.fontXS,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
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
