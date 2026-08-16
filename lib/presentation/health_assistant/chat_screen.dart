import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.healthAssistant)),
      body: const Center(
        child: Text('AI Health Assistant - Coming Soon'),
      ),
    );
  }
}
