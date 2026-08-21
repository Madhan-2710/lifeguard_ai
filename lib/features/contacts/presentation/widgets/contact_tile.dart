import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/emergency_contact.dart';

/// A single emergency contact card with edit / delete / set-primary actions.
///
/// Used by the contacts list screen. All actions are delegated to the
/// provided callbacks so the widget stays presentation-only.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
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
