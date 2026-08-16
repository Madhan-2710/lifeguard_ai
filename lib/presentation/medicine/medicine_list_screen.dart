import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../router/app_router.dart';

class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myMedicines)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addMedicine),
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text('Medicine List - Coming Soon')),
    );
  }
}
