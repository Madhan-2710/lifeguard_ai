import 'package:flutter/material.dart';

import 'edit_medicine_screen.dart';

/// Add a new medicine.
///
/// Delegates to [EditMedicineScreen] which handles both add and edit flows.
class AddMedicineScreen extends StatelessWidget {
  const AddMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditMedicineScreen();
  }
}
