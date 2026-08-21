import '../../domain/entities/health_assistant_response.dart';
import '../../domain/repositories/health_assistant_repository.dart';
import '../datasources/health_assistant_data_source.dart';

/// Pass-through repository that delegates to the local response engine.
class HealthAssistantRepositoryImpl implements HealthAssistantRepository {
  HealthAssistantRepositoryImpl(this._dataSource);

  final HealthAssistantDataSource _dataSource;

  @override
  Future<HealthAssistantResponse> getResponse(String userMessage) {
    return _dataSource.getResponse(userMessage);
  }
}
