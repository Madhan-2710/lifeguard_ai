import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship = 'Other',
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    relationship,
    isPrimary,
    createdAt,
    updatedAt,
  ];
}
