import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/chat_message.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/health_assistant_response.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/health_context.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/repositories/health_assistant_repository.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/services/health_context_builder.dart';
import 'package:lifeguard_ai/features/health_assistant/presentation/cubit/health_assistant_cubit.dart';

void main() {
  group('HealthAssistantCubit with medical context', () {
    test('profile fetch failure → chatbot still works', () async {
      final cubit = HealthAssistantCubit(
        repository: _FakeRepository(),
        contextBuilder: _FakeContextBuilder(
          () async => throw Exception('profile fetch failed'),
        ),
      );

      await cubit.sendMessage('What can I take for a headache?');

      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.messages.last.sender, ChatSender.assistant);
      expect(cubit.state.messages.last.text, isNotEmpty);
      expect(cubit.state.isUsingProfileContext, isFalse);
      cubit.close();
    });

    test('medicine fetch failure → chatbot still works', () async {
      final cubit = HealthAssistantCubit(
        repository: _FakeRepository(),
        contextBuilder: _FakeContextBuilder(
          () async => throw Exception('medicine fetch failed'),
        ),
      );

      await cubit.sendMessage('What can I take for a headache?');

      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.messages.last.sender, ChatSender.assistant);
      expect(cubit.state.isUsingProfileContext, isFalse);
      cubit.close();
    });

    test('context builder failure → chatbot still works', () async {
      final cubit = HealthAssistantCubit(
        repository: _FakeRepository(),
        contextBuilder: _FakeContextBuilder(
          () async => throw Exception('builder failed'),
        ),
      );

      await cubit.sendMessage('What can I take for a headache?');

      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.messages.last.sender, ChatSender.assistant);
      expect(cubit.state.isUsingProfileContext, isFalse);
      cubit.close();
    });

    test('loaded profile context sets isUsingProfileContext', () async {
      final cubit = HealthAssistantCubit(
        repository: _FakeRepository(),
        contextBuilder: _FakeContextBuilder(
          () async => const HealthContext(
            allergies: ['ibuprofen'],
            currentMedicines: ['Metformin'],
          ),
        ),
      );

      await cubit.sendMessage('What can I take for a headache?');

      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.isUsingProfileContext, isTrue);
      expect(cubit.state.messages.last.sender, ChatSender.assistant);
      cubit.close();
    });

    test('empty profile context does not set isUsingProfileContext', () async {
      final cubit = HealthAssistantCubit(
        repository: _FakeRepository(),
        contextBuilder: _FakeContextBuilder(() async => const HealthContext()),
      );

      await cubit.sendMessage('What can I take for a headache?');

      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.isUsingProfileContext, isFalse);
      cubit.close();
    });

    test('no context builder → assistant still works without profile', () async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());

      await cubit.sendMessage('What can I take for a headache?');

      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.messages.last.sender, ChatSender.assistant);
      expect(cubit.state.isUsingProfileContext, isFalse);
      cubit.close();
    });

    test('context is loaded once and reused across messages', () async {
      var buildCount = 0;
      final cubit = HealthAssistantCubit(
        repository: _FakeRepository(),
        contextBuilder: _FakeContextBuilder(() async {
          buildCount++;
          return const HealthContext(allergies: ['ibuprofen']);
        }),
      );

      await cubit.sendMessage('What can I take for a headache?');
      await cubit.sendMessage('What can I take for a fever?');

      expect(buildCount, 1);
      expect(cubit.state.isUsingProfileContext, isTrue);
      cubit.close();
    });

    test('emergency message still recommends SOS with profile context',
        () async {
      final cubit = HealthAssistantCubit(
        repository: _FakeRepository(),
        contextBuilder: _FakeContextBuilder(
          () async => const HealthContext(chronicConditions: ['asthma']),
        ),
      );

      await cubit.sendMessage('I am having severe breathing difficulty');

      expect(cubit.state.sosRecommended, isTrue);
      cubit.close();
    });
  });
}

class _FakeRepository implements HealthAssistantRepository {
  @override
  Future<HealthAssistantResponse> getResponse(
    String userMessage, {
    HealthContext? context,
  }) async {
    final text = userMessage.toLowerCase();
    final serious = text.contains('chest') ||
        text.contains('bleed') ||
        text.contains('breath') ||
        text.contains('unconscious') ||
        text.contains('fall');
    return HealthAssistantResponse(
      text: 'Guidance for: $userMessage',
      sosRecommended: serious,
    );
  }
}

class _FakeContextBuilder implements HealthContextBuilder {
  _FakeContextBuilder(this._build);

  final Future<HealthContext> Function() _build;

  @override
  Future<HealthContext> build() => _build();
}
