import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class Login extends UseCase<void, LoginParams> {
  Login(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  const LoginParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
