import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicines_repository.dart';
import 'medicines_state.dart';

class MedicinesCubit extends Cubit<MedicinesState> {
  MedicinesCubit({required this._repository})
    : super(const MedicinesState());

  final MedicinesRepository _repository;

  Future<void> loadMedicines() async {
    emit(state.copyWith(status: MedicinesStatus.loading));
    try {
      final medicines = await _repository.getMedicines();
      emit(
        state.copyWith(status: MedicinesStatus.loaded, medicines: medicines),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicinesStatus.failure,
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> addMedicine(Medicine medicine) async {
    emit(state.copyWith(status: MedicinesStatus.saving));
    try {
      await _repository.addMedicine(medicine);
      final updated = await _repository.getMedicines();
      emit(
        state.copyWith(
          status: MedicinesStatus.success,
          medicines: updated,
          message: 'Medicine added',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicinesStatus.failure,
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> updateMedicine(Medicine medicine) async {
    emit(state.copyWith(status: MedicinesStatus.saving));
    try {
      await _repository.updateMedicine(medicine);
      final updated = await _repository.getMedicines();
      emit(
        state.copyWith(
          status: MedicinesStatus.success,
          medicines: updated,
          message: 'Medicine updated',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicinesStatus.failure,
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    emit(state.copyWith(status: MedicinesStatus.saving));
    try {
      await _repository.deleteMedicine(medicineId);
      final updated = await _repository.getMedicines();
      emit(
        state.copyWith(
          status: MedicinesStatus.success,
          medicines: updated,
          message: 'Medicine deleted',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicinesStatus.failure,
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: MedicinesStatus.loaded, message: null));
  }
}
