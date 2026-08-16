import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class AddMedicineScreen extends StatelessWidget {
  const AddMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addMedicine)),
      body: const Center(child: Text('Add Medicine - Coming Soon')),
    );
  }
}
