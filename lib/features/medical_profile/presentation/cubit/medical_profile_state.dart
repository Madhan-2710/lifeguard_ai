import 'package:equatable/equatable.dart';

import '../../domain/entities/medical_profile.dart';

enum MedicalProfileStatus { initial, loading, loaded, saving, success, failure }

class MedicalProfileState extends Equatable {
  const MedicalProfileState({
    this.status = MedicalProfileStatus.initial,
    this.profile = const MedicalProfile(),
    this.message,
  });

  final MedicalProfileStatus status;
  final MedicalProfile profile;
  final String? message;

  MedicalProfileState copyWith({
    MedicalProfileStatus? status,
    MedicalProfile? profile,
    String? message,
    bool clearMessage = false,
  }) {
    return MedicalProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, profile, message];
}
