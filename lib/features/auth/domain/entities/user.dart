import 'package:equatable/equatable.dart';

/// Core user entity for the authentication domain layer.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.fullName = '',
    this.phoneNumber = '',
    this.photoUrl,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const empty = UserEntity(id: '', email: '');

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phoneNumber,
    photoUrl,
    isEmailVerified,
    createdAt,
    updatedAt,
  ];
}
