import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class FallDetectionScreen extends StatelessWidget {
  const FallDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.fallDetection)),
      body: const Center(child: Text('Fall Detection - Coming Soon')),
    );
  }
}
