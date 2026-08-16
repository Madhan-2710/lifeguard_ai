import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/emergency_contact_model.dart';

abstract class ContactsDataSource {
  Future<List<EmergencyContactModel>> getContacts();
  Future<EmergencyContactModel> addContact(EmergencyContactModel contact);
  Future<EmergencyContactModel> updateContact(EmergencyContactModel contact);
  Future<void> deleteContact(String contactId);
  Future<void> setPrimaryContact(String contactId);
}

class ContactsDataSourceImpl implements ContactsDataSource {
  ContactsDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SharedPreferences? sharedPreferences,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = sharedPreferences;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String get _currentUserId {
    final user = _auth.currentUser;
    return user?.uid ?? 'local_user';
  }

  CollectionReference<Map<String, dynamic>> get _userContactsRef {
    final uid = _currentUserId;
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.emergencyContactsCollection);
  }

  @override
  Future<List<EmergencyContactModel>> getContacts() async {
    try {
      final List<EmergencyContactModel> contacts = [];
      final uid = _currentUserId;

      if (uid != 'local_user') {
        try {
          final snapshot = await _userContactsRef
              .orderBy(FirebaseConstants.createdAt, descending: false)
              .get();

          for (final doc in snapshot.docs) {
            contacts.add(EmergencyContactModel.fromMap(doc.data(), doc.id));
          }

          // Cache locally for offline emergency use
          await _cacheContactsLocally(contacts);
          return contacts;
        } catch (_) {
          // If Firestore fails (e.g. offline), fallback to local cache
        }
      }

      // Read from local cache
      return await _getLocalContacts();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch emergency contacts: $e');
    }
  }

  @override
  Future<EmergencyContactModel> addContact(EmergencyContactModel contact) async {
    try {
      final uid = _currentUserId;
      EmergencyContactModel newContact = contact;

      if (uid != 'local_user') {
        final docRef = contact.id.isNotEmpty
            ? _userContactsRef.doc(contact.id)
            : _userContactsRef.doc();

        newContact = EmergencyContactModel(
          id: docRef.id,
          name: contact.name,
          phoneNumber: contact.phoneNumber,
          relationship: contact.relationship,
          isPrimary: contact.isPrimary,
          createdAt: contact.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await docRef.set(newContact.toMap());
      } else {
        newContact = EmergencyContactModel(
          id: contact.id.isNotEmpty
              ? contact.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          name: contact.name,
          phoneNumber: contact.phoneNumber,
          relationship: contact.relationship,
          isPrimary: contact.isPrimary,
          createdAt: contact.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final existing = await getContacts();
      final updatedList = List<EmergencyContactModel>.from(existing);

      if (newContact.isPrimary) {
        for (var i = 0; i < updatedList.length; i++) {
          if (updatedList[i].isPrimary && updatedList[i].id != newContact.id) {
            final demoted = EmergencyContactModel(
              id: updatedList[i].id,
              name: updatedList[i].name,
              phoneNumber: updatedList[i].phoneNumber,
              relationship: updatedList[i].relationship,
              isPrimary: false,
              createdAt: updatedList[i].createdAt,
              updatedAt: DateTime.now(),
            );
            updatedList[i] = demoted;
            if (uid != 'local_user') {
              await _userContactsRef.doc(demoted.id).update(demoted.toMap());
            }
          }
        }
      }

      updatedList.add(newContact);
      await _cacheContactsLocally(updatedList);

      return newContact;
    } catch (e) {
      throw ServerException(message: 'Failed to add emergency contact: $e');
    }
  }

  @override
  Future<EmergencyContactModel> updateContact(EmergencyContactModel contact) async {
    try {
      final uid = _currentUserId;
      final updatedContact = EmergencyContactModel(
        id: contact.id,
        name: contact.name,
        phoneNumber: contact.phoneNumber,
        relationship: contact.relationship,
        isPrimary: contact.isPrimary,
        createdAt: contact.createdAt,
        updatedAt: DateTime.now(),
      );

      if (uid != 'local_user') {
        await _userContactsRef.doc(contact.id).update(updatedContact.toMap());
      }

      final existing = await getContacts();
      final updatedList = <EmergencyContactModel>[];
      for (final c in existing) {
        if (c.id == contact.id) {
          updatedList.add(updatedContact);
        } else if (contact.isPrimary && c.isPrimary) {
          final demoted = EmergencyContactModel(
            id: c.id,
            name: c.name,
            phoneNumber: c.phoneNumber,
            relationship: c.relationship,
            isPrimary: false,
            createdAt: c.createdAt,
            updatedAt: DateTime.now(),
          );
          if (uid != 'local_user') {
            await _userContactsRef.doc(c.id).update(demoted.toMap());
          }
          updatedList.add(demoted);
        } else {
          updatedList.add(c);
        }
      }

      await _cacheContactsLocally(updatedList);
      return updatedContact;
    } catch (e) {
      throw ServerException(message: 'Failed to update emergency contact: $e');
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      final uid = _currentUserId;
      if (uid != 'local_user') {
        await _userContactsRef.doc(contactId).delete();
      }

      final existing = await getContacts();
      final updatedList = existing.where((c) => c.id != contactId).toList();
      await _cacheContactsLocally(updatedList);
    } catch (e) {
      throw ServerException(message: 'Failed to delete emergency contact: $e');
    }
  }

  @override
  Future<void> setPrimaryContact(String contactId) async {
    try {
      final existing = await getContacts();
      for (final c in existing) {
        final isTarget = c.id == contactId;
        if (c.isPrimary != isTarget) {
          await updateContact(
            EmergencyContactModel(
              id: c.id,
              name: c.name,
              phoneNumber: c.phoneNumber,
              relationship: c.relationship,
              isPrimary: isTarget,
              createdAt: c.createdAt,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      throw ServerException(message: 'Failed to set primary contact: $e');
    }
  }

  Future<void> _cacheContactsLocally(List<EmergencyContactModel> contacts) async {
    final prefs = await _getPrefs();
    final jsonList = contacts.map((c) => c.toMap()).toList();
    await prefs.setString(FirebaseConstants.prefSosContacts, jsonEncode(jsonList));
  }

  Future<List<EmergencyContactModel>> _getLocalContacts() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(FirebaseConstants.prefSosContacts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => EmergencyContactModel.fromMap(
                item as Map<String, dynamic>,
                item[FirebaseConstants.contactId]?.toString() ?? '',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
