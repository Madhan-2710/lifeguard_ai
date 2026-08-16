import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser extends UseCase<UserEntity?, NoParams> {
  GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<UserEntity?> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
