import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckAuthenticationStatus extends UseCase<bool, NoParams> {
  CheckAuthenticationStatus(this._repository);

  final AuthRepository _repository;

  @override
  Future<bool> call(NoParams params) {
    return _repository.isAuthenticated();
  }
}
