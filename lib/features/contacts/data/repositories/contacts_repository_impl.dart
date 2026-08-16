import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_data_source.dart';
import '../models/emergency_contact_model.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this._dataSource);

  final ContactsDataSource _dataSource;

  @override
  Future<List<EmergencyContact>> getContacts() async {
    return await _dataSource.getContacts();
  }

  @override
  Future<EmergencyContact> addContact(EmergencyContact contact) async {
    final model = EmergencyContactModel.fromEntity(contact);
    return await _dataSource.addContact(model);
  }

  @override
  Future<EmergencyContact> updateContact(EmergencyContact contact) async {
    final model = EmergencyContactModel.fromEntity(contact);
    return await _dataSource.updateContact(model);
  }

  @override
  Future<void> deleteContact(String contactId) async {
    await _dataSource.deleteContact(contactId);
  }

  @override
  Future<void> setPrimaryContact(String contactId) async {
    await _dataSource.setPrimaryContact(contactId);
  }
}
