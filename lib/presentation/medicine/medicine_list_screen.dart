import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/medicine_reminder_service.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/medicine/domain/entities/medicine.dart';
import '../../features/medicine/presentation/cubit/medicines_cubit.dart';
import '../../features/medicine/presentation/cubit/medicines_state.dart';
import '../router/app_router.dart';

/// List of the authenticated user's medicines with add / edit / delete /
/// active-toggle actions.
class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MedicinesCubit>().loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myMedicines)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addMedicine),
        tooltip: AppStrings.addMedicine,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<MedicinesCubit, MedicinesState>(
        listener: _handleState,
        builder: (context, state) {
          if (state.status == MedicinesStatus.loading &&
              state.medicines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MedicinesStatus.failure &&
              state.medicines.isEmpty) {
            return _MedicinesErrorState(
              onRetry: () => context.read<MedicinesCubit>().loadMedicines(),
            );
          }
          if (state.medicines.isEmpty) {
            return _MedicinesEmptyState(
              onAdd: () => context.push(AppRoutes.addMedicine),
            );
          }
          return _MedicinesList(medicines: state.medicines);
        },
      ),
    );
  }

  void _handleState(BuildContext context, MedicinesState state) {
    if (state.status == MedicinesStatus.failure && state.message != null) {
      Helpers.showErrorSnackBar(context, state.message!);
    } else if (state.status == MedicinesStatus.success &&
        state.message != null) {
      Helpers.showSuccessSnackBar(context, state.message!);
      context.read<MedicinesCubit>().resetStatus();
    }
  }
}

class _MedicinesList extends StatelessWidget {
  const _MedicinesList({required this.medicines});

  final List<Medicine> medicines;

  @override
  Widget build(BuildContext context) {
    final sorted = [...medicines]..sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

    return RefreshIndicator(
      onRefresh: () => context.read<MedicinesCubit>().loadMedicines(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSM),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final medicine = sorted[index];
          return _MedicineTile(
            medicine: medicine,
            onEdit: () => context.push(AppRoutes.editMedicine, extra: medicine),
            onDelete: () => _confirmDelete(context, medicine),
            onToggleActive: () => _toggleActive(context, medicine),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Medicine medicine,
  ) async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: AppStrings.deleteMedicineConfirmTitle,
      message: AppStrings.deleteMedicineConfirmMessage,
      confirmText: AppStrings.deleteMedicine,
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      await context.read<MedicineReminderService>().cancelMedicineReminders(
        medicine.id,
      );
      if (context.mounted) {
        context.read<MedicinesCubit>().deleteMedicine(medicine.id);
      }
    }
  }

  Future<void> _toggleActive(BuildContext context, Medicine medicine) async {
    final updated = medicine.copyWith(isActive: !medicine.isActive);
    await context.read<MedicineReminderService>().scheduleMedicineReminders(
      updated,
    );
    if (context.mounted) {
      context.read<MedicinesCubit>().updateMedicine(updated);
    }
  }
}

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final reminderText = medicine.reminderTimes.isEmpty
        ? AppStrings.noReminderTimes
        : medicine.reminderTimes
              .map((t) => Helpers.formatTimeFromParts(t.hour, t.minute))
              .join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: medicine.isActive
                        ? AppColors.skyBlue
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: medicine.isActive
                        ? AppColors.primaryBlue
                        : AppColors.greyMedium,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLG,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (medicine.dosage.isNotEmpty)
                        Text(
                          medicine.dosage,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppDimensions.fontMD,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: AppStrings.editMedicine,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: AppStrings.deleteMedicine,
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            if (medicine.frequency.isNotEmpty)
              _InfoRow(
                icon: Icons.repeat_outlined,
                text: medicine.frequency,
              ),
            if (medicine.reminderTimes.isNotEmpty)
              _InfoRow(
                icon: Icons.alarm_outlined,
                text: reminderText,
              ),
            if (medicine.prescribedBy.isNotEmpty)
              _InfoRow(
                icon: Icons.local_hospital_outlined,
                text: medicine.prescribedBy,
              ),
            const SizedBox(height: AppDimensions.paddingSM),
            Row(
              children: [
                Switch(
                  value: medicine.isActive,
                  onChanged: (_) => onToggleActive(),
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                Text(
                  medicine.isActive
                      ? AppStrings.activeMedicine
                      : AppStrings.inactiveMedicine,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSM,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.greyMedium),
          const SizedBox(width: AppDimensions.paddingSM),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppDimensions.fontSM,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicinesEmptyState extends StatelessWidget {
  const _MedicinesEmptyState({required this.onAdd});

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
                Icons.medication_outlined,
                size: AppDimensions.iconXL,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text(
              AppStrings.noMedicines,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            Text(
              AppStrings.noMedicinesDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            CustomButton(
              label: AppStrings.addMedicine,
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicinesErrorState extends StatelessWidget {
  const _MedicinesErrorState({required this.onRetry});

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
