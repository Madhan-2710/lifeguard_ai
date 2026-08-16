import '../../domain/entities/emergency_event.dart';
import '../../domain/repositories/emergency_event_repository.dart';
import '../datasources/emergency_event_data_source.dart';
import '../models/emergency_event_model.dart';

class EmergencyEventRepositoryImpl implements EmergencyEventRepository {
  EmergencyEventRepositoryImpl(this._dataSource);

  final EmergencyEventDataSource _dataSource;

  @override
  Future<EmergencyEvent> createEvent(EmergencyEvent event) async {
    final model = EmergencyEventModel.fromEntity(event);
    return await _dataSource.createEvent(model);
  }

  @override
  Future<EmergencyEvent> updateEventStatus(
    String eventId,
    EmergencyEventStatus status, {
    String? message,
  }) async {
    return await _dataSource.updateEventStatus(
      eventId,
      status,
      message: message,
    );
  }

  @override
  Future<EmergencyEvent?> getEvent(String eventId) async {
    return await _dataSource.getEvent(eventId);
  }
}
