import '../../domain/entities/medical_profile.dart';
import '../../domain/repositories/medical_profile_repository.dart';
import '../datasources/medical_profile_data_source.dart';
import '../models/medical_profile_model.dart';

class MedicalProfileRepositoryImpl implements MedicalProfileRepository {
  MedicalProfileRepositoryImpl(this._dataSource);

  final MedicalProfileDataSource _dataSource;

  @override
  Future<MedicalProfile?> getProfile() async {
    return await _dataSource.getProfile();
  }

  @override
  Future<MedicalProfile> saveProfile(MedicalProfile profile) async {
    final model = MedicalProfileModel.fromEntity(profile);
    return await _dataSource.saveProfile(model);
  }
}
