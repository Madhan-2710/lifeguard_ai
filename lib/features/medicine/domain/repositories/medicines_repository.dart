import '../entities/medicine.dart';

/// Repository for the authenticated user's medicines.
abstract class MedicinesRepository {
  Future<List<Medicine>> getMedicines();
  Future<Medicine> addMedicine(Medicine medicine);
  Future<Medicine> updateMedicine(Medicine medicine);
  Future<void> deleteMedicine(String medicineId);
}
