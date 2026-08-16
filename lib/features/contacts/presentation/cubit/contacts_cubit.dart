import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/contacts_repository.dart';
import 'contacts_state.dart';

/// Cubit that coordinates the emergency contacts flow.
///
/// All persistence is delegated to the [ContactsRepository] so the widget
/// layer never talks to Firebase directly. The repository is the single
/// entry point that the future SOS / fall-detection modules will use to
/// read contacts, keeping this presentation cubit out of that path.
class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({required ContactsRepository contactsRepository})
    : _repository = contactsRepository,
      super(const ContactsState());

  final ContactsRepository _repository;

  Future<void> loadContacts() async {
    emit(state.copyWith(status: ContactsStatus.loading));
    try {
      final contacts = await _repository.getContacts();
      emit(state.copyWith(status: ContactsStatus.loaded, contacts: contacts));
    } catch (e) {
      emit(
        state.copyWith(
          status: ContactsStatus.failure,
          message: _mapError(e),
        ),
      );
    }
  }

  Future<void> addContact(EmergencyContact contact) async {
    emit(state.copyWith(status: ContactsStatus.loading));
    try {
      await _repository.addContact(contact);
      final updated = await _repository.getContacts();
      emit(
        state.copyWith(
          status: ContactsStatus.success,
          contacts: updated,
          message: AppStrings.contactAdded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContactsStatus.failure,
          message: _mapError(e),
        ),
      );
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    emit(state.copyWith(status: ContactsStatus.loading));
    try {
      await _repository.updateContact(contact);
      final updated = await _repository.getContacts();
      emit(
        state.copyWith(
          status: ContactsStatus.success,
          contacts: updated,
          message: AppStrings.contactUpdated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContactsStatus.failure,
          message: _mapError(e),
        ),
      );
    }
  }

  Future<void> deleteContact(String contactId) async {
    emit(state.copyWith(status: ContactsStatus.loading));
    try {
      await _repository.deleteContact(contactId);
      final updated = await _repository.getContacts();
      emit(
        state.copyWith(
          status: ContactsStatus.success,
          contacts: updated,
          message: AppStrings.contactDeleted,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContactsStatus.failure,
          message: _mapError(e),
        ),
      );
    }
  }

  Future<void> setPrimaryContact(String contactId) async {
    emit(state.copyWith(status: ContactsStatus.loading));
    try {
      await _repository.setPrimaryContact(contactId);
      final updated = await _repository.getContacts();
      emit(
        state.copyWith(
          status: ContactsStatus.success,
          contacts: updated,
          message: AppStrings.primaryContactUpdated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContactsStatus.failure,
          message: _mapError(e),
        ),
      );
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: ContactsStatus.loaded, clearMessage: true));
  }

  /// Maps any thrown error to a user-facing message, preferring the message
  /// carried by the app's own [AppException] types.
  String _mapError(Object error) {
    if (error is AppException && error.message.isNotEmpty) {
      return error.message;
    }
    return AppStrings.somethingWentWrong;
  }
}
