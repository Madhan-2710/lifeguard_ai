import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../router/app_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.skyBlue,
                      child: const Icon(Icons.person, size: 30, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: AppDimensions.paddingMD),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${AppStrings.hello}, User!', style: const TextStyle(fontSize: AppDimensions.fontXL, fontWeight: FontWeight.bold)),
                        const Text('Health status: Good', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            // Quick Access Grid
            const Text(AppStrings.quickAccess, style: TextStyle(fontSize: AppDimensions.fontXL, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingMD),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: const [
                _QuickAccessCard(icon: Icons.chat, label: AppStrings.aiHealthAssistant, color: AppColors.primaryBlue, route: AppRoutes.healthAssistant),
                _QuickAccessCard(icon: Icons.sensors, label: AppStrings.fallDetection, color: AppColors.accentBlue, route: AppRoutes.fallDetection),
                _QuickAccessCard(icon: Icons.medication, label: AppStrings.medicineReminder, color: AppColors.success, route: AppRoutes.medicines),
                _QuickAccessCard(icon: Icons.contacts, label: AppStrings.emergencyContacts, color: AppColors.warning, route: AppRoutes.contacts),
                _QuickAccessCard(icon: Icons.folder, label: AppStrings.healthRecords, color: AppColors.info, route: AppRoutes.healthRecords),
                _QuickAccessCard(icon: Icons.person, label: 'My Profile', color: AppColors.greyDark, route: AppRoutes.profile),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAccessCard({required this.icon, required this.label, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
