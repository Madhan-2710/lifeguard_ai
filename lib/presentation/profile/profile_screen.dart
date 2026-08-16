import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        } else if (state.status == AuthStatus.failure &&
            state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(context),
            const SizedBox(height: AppDimensions.paddingLG),

            // Health Information
            _buildSectionTitle(context, AppStrings.medicalInfo),
            const SizedBox(height: AppDimensions.paddingSM),
            _buildInfoCard(context),

            const SizedBox(height: AppDimensions.paddingLG),

            // Emergency Contact Section
            _buildSectionTitle(context, AppStrings.emergencyContacts),
            const SizedBox(height: AppDimensions.paddingSM),
            _buildEmergencyContactSection(context),

            const SizedBox(height: AppDimensions.paddingLG),

            // Settings & Logout
            _buildMenuItems(context),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            const Text(
              'User Name',
              style: TextStyle(
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXS),
            Text(
              'user@example.com',
              style: TextStyle(
                fontSize: AppDimensions.fontMD,
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.editProfile),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(AppStrings.editProfile),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXS),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            _buildInfoRow(Icons.bloodtype, 'Blood Type', 'Not Set'),
            const Divider(),
            _buildInfoRow(Icons.warning_amber, 'Allergies', 'None listed'),
            const Divider(),
            _buildInfoRow(Icons.medical_information, 'Conditions', 'None listed'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSM),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: AppDimensions.paddingMD),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppDimensions.fontMD,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppDimensions.fontMD,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            _buildContactPlaceholder(context),
            const SizedBox(height: AppDimensions.paddingSM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.contacts),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addContact),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLG),
      child: Column(
        children: [
          Icon(
            Icons.emergency_share,
            size: 40,
            color: AppColors.greyMedium.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            AppStrings.noContacts,
            style: TextStyle(
              color: AppColors.greyMedium.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.medical_services_outlined,
          title: AppStrings.healthRecords,
          onTap: () => context.go(AppRoutes.healthRecords),
        ),
        const SizedBox(height: AppDimensions.paddingSM),
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {},
        ),
        const SizedBox(height: AppDimensions.paddingSM),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: AppStrings.about,
          onTap: () {},
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text(AppStrings.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        side: const BorderSide(color: AppColors.greyLight),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppDimensions.fontMD,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.greyMedium),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
