import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_contact.dart';

enum ContactsStatus { initial, loading, loaded, success, failure }

class ContactsState extends Equatable {
  const ContactsState({
    this.status = ContactsStatus.initial,
    this.contacts = const [],
    this.message,
  });

  final ContactsStatus status;
  final List<EmergencyContact> contacts;
  final String? message;

  EmergencyContact? get primaryContact {
    try {
      return contacts.firstWhere((c) => c.isPrimary);
    } catch (_) {
      return contacts.isNotEmpty ? contacts.first : null;
    }
  }

  ContactsState copyWith({
    ContactsStatus? status,
    List<EmergencyContact>? contacts,
    String? message,
    bool clearMessage = false,
  }) {
    return ContactsState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, contacts, message];
}
