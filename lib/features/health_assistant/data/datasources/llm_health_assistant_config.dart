/// Configuration for the LLM-backed health assistant data source.
///
/// Values are read from compile-time `--dart-define` flags so no API key is
/// ever hardcoded in source:
///
///   flutter run --dart-define=HEALTH_ASSISTANT_PROVIDER=llm \
///               --dart-define=LLM_API_KEY=sk-... \
///               --dart-define=LLM_API_URL=https://api.openai.com/v1/chat/completions \
///               --dart-define=LLM_MODEL=gpt-4o-mini \
///               --dart-define=LLM_TIMEOUT_SECONDS=20
///
/// When no credential is available the provider stays `local` and the app
/// keeps using the offline response engine.
enum HealthAssistantProvider { local, llm }

class LlmHealthAssistantConfig {
  const LlmHealthAssistantConfig({
    this.provider = HealthAssistantProvider.local,
    this.apiKey = '',
    this.apiUrl = defaultApiUrl,
    this.model = defaultModel,
    this.timeout = const Duration(seconds: 20),
  });

  static const String defaultApiUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String defaultModel = 'gpt-4o-mini';

  /// Builds the config from `--dart-define` flags with safe defaults.
  factory LlmHealthAssistantConfig.fromEnvironment() {
    const provider = String.fromEnvironment('HEALTH_ASSISTANT_PROVIDER');
    const apiKey = String.fromEnvironment('LLM_API_KEY');
    const apiUrl = String.fromEnvironment('LLM_API_URL');
    const model = String.fromEnvironment('LLM_MODEL');
    const timeoutSeconds = int.fromEnvironment(
      'LLM_TIMEOUT_SECONDS',
      defaultValue: 20,
    );
    return LlmHealthAssistantConfig(
      provider: provider == 'llm'
          ? HealthAssistantProvider.llm
          : HealthAssistantProvider.local,
      apiKey: apiKey,
      apiUrl: apiUrl.isEmpty ? defaultApiUrl : apiUrl,
      model: model.isEmpty ? defaultModel : model,
      timeout: Duration(seconds: timeoutSeconds),
    );
  }

  final HealthAssistantProvider provider;
  final String apiKey;
  final String apiUrl;
  final String model;
  final Duration timeout;

  /// True when the LLM provider is selected AND a credential is available.
  bool get useLlm =>
      provider == HealthAssistantProvider.llm && apiKey.isNotEmpty;
}
