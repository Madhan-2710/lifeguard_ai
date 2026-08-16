import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPassword extends UseCase<void, ForgotPasswordParams> {
  ForgotPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(ForgotPasswordParams params) {
    return _repository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams {
  const ForgotPasswordParams({required this.email});

  final String email;
}
