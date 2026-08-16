import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class Register extends UseCase<void, RegisterParams> {
  Register(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(RegisterParams params) {
    return _repository.register(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}

class RegisterParams {
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
}
