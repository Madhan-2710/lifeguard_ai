import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.healthRecords)),
      body: const Center(child: Text('Health Records - Coming Soon')),
    );
  }
}
