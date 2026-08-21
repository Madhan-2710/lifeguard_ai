import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/medical_profile.dart';
import '../../domain/repositories/medical_profile_repository.dart';
import 'medical_profile_state.dart';

class MedicalProfileCubit extends Cubit<MedicalProfileState> {
  MedicalProfileCubit({required this._repository})
    : super(const MedicalProfileState());

  final MedicalProfileRepository _repository;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: MedicalProfileStatus.loading));
    try {
      final profile = await _repository.getProfile();
      emit(
        state.copyWith(
          status: MedicalProfileStatus.loaded,
          profile: profile ?? const MedicalProfile(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicalProfileStatus.failure,
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> saveProfile(MedicalProfile profile) async {
    emit(state.copyWith(status: MedicalProfileStatus.saving));
    try {
      final saved = await _repository.saveProfile(profile);
      emit(
        state.copyWith(
          status: MedicalProfileStatus.success,
          profile: saved,
          message: 'Medical profile saved',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicalProfileStatus.failure,
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: MedicalProfileStatus.loaded, message: null));
  }
}
