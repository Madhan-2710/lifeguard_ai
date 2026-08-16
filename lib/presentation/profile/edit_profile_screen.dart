import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: const Center(child: Text('Edit Profile - Coming Soon')),
    );
  }
}
