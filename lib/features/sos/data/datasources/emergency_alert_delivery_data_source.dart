import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/emergency_alert_delivery.dart';

/// Calls the Firebase HTTPS callable function without exposing Twilio data.
abstract class EmergencyAlertDeliveryDataSource {
  Future<EmergencyAlertDeliveryResult> deliverEmergencyAlert({
    required String eventId,
  });
}

class EmergencyAlertDeliveryDataSourceImpl
    implements EmergencyAlertDeliveryDataSource {
  EmergencyAlertDeliveryDataSourceImpl({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<EmergencyAlertDeliveryResult> deliverEmergencyAlert({
    required String eventId,
  }) async {
    final callable = _functions.httpsCallable('sendEmergencyAlert');
    final response = await callable.call<Map<String, dynamic>>({'eventId': eventId});
    final data = Map<String, dynamic>.from(response.data);

    return EmergencyAlertDeliveryResult(
      eventId: data['eventId']?.toString() ?? eventId,
      status: _statusFrom(data['deliveryStatus']?.toString()),
      successfulContactIds: _stringList(data['successfulContactIds']),
      failedContactIds: _stringList(data['failedContactIds']),
      error: data['deliveryError']?.toString(),
      alreadyDelivered: data['alreadyDelivered'] == true,
      deliveryInProgress: data['deliveryInProgress'] == true,
    );
  }

  EmergencyAlertDeliveryStatus _statusFrom(String? value) {
    return EmergencyAlertDeliveryStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => EmergencyAlertDeliveryStatus.failed,
    );
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList(growable: false);
  }
}
