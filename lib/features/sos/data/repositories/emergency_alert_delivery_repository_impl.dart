import '../../domain/entities/emergency_alert_delivery.dart';
import '../../domain/repositories/emergency_alert_delivery_repository.dart';
import '../datasources/emergency_alert_delivery_data_source.dart';

class EmergencyAlertDeliveryRepositoryImpl
    implements EmergencyAlertDeliveryRepository {
  EmergencyAlertDeliveryRepositoryImpl(this._dataSource);

  final EmergencyAlertDeliveryDataSource _dataSource;

  @override
  Future<EmergencyAlertDeliveryResult> deliverEmergencyAlert({
    required String eventId,
  }) {
    if (eventId.trim().isEmpty) {
      throw ArgumentError.value(eventId, 'eventId', 'must not be empty');
    }
    return _dataSource.deliverEmergencyAlert(eventId: eventId.trim());
  }
}
