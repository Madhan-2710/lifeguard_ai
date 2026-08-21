import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../datasources/medicines_data_source.dart';
import '../models/medicine_model.dart';

class MedicinesRepositoryImpl implements MedicinesRepository {
  MedicinesRepositoryImpl(this._dataSource);

  final MedicinesDataSource _dataSource;

  @override
  Future<List<Medicine>> getMedicines() async {
    return await _dataSource.getMedicines();
  }

  @override
  Future<Medicine> addMedicine(Medicine medicine) async {
    final model = MedicineModel.fromEntity(medicine);
    return await _dataSource.addMedicine(model);
  }

  @override
  Future<Medicine> updateMedicine(Medicine medicine) async {
    final model = MedicineModel.fromEntity(medicine);
    return await _dataSource.updateMedicine(model);
  }

  @override
  Future<void> deleteMedicine(String medicineId) async {
    await _dataSource.deleteMedicine(medicineId);
  }
}
