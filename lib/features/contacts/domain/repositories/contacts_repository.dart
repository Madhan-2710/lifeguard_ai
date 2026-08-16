import '../entities/emergency_contact.dart';

abstract class ContactsRepository {
  Future<List<EmergencyContact>> getContacts();
  Future<EmergencyContact> addContact(EmergencyContact contact);
  Future<EmergencyContact> updateContact(EmergencyContact contact);
  Future<void> deleteContact(String contactId);
  Future<void> setPrimaryContact(String contactId);
}
