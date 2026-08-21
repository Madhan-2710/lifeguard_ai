import 'package:equatable/equatable.dart';

import '../../domain/entities/medicine.dart';

enum MedicinesStatus { initial, loading, loaded, saving, success, failure }

class MedicinesState extends Equatable {
  const MedicinesState({
    this.status = MedicinesStatus.initial,
    this.medicines = const [],
    this.message,
  });

  final MedicinesStatus status;
  final List<Medicine> medicines;
  final String? message;

  List<Medicine> get activeMedicines =>
      medicines.where((m) => m.isActive).toList();

  MedicinesState copyWith({
    MedicinesStatus? status,
    List<Medicine>? medicines,
    String? message,
    bool clearMessage = false,
  }) {
    return MedicinesState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, medicines, message];
}
