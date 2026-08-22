import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/chat_message.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/health_assistant_response.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/health_context.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/repositories/health_assistant_repository.dart';
import 'package:lifeguard_ai/features/health_assistant/presentation/cubit/health_assistant_cubit.dart';

void main() {
  group('HealthAssistantCubit', () {
    test('starts with a welcome message from the assistant', () {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      expect(cubit.state.messages, hasLength(1));
      expect(cubit.state.messages.first.sender, ChatSender.assistant);
      expect(cubit.state.isResponding, isFalse);
      cubit.close();
    });

    test('sendMessage appends user and assistant messages', () async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await cubit.sendMessage('How do I treat a small cut?');
      expect(cubit.state.messages, hasLength(3)); // welcome + user + assistant
      expect(cubit.state.messages[1].sender, ChatSender.user);
      expect(cubit.state.messages[1].text, 'How do I treat a small cut?');
      expect(cubit.state.messages[2].sender, ChatSender.assistant);
      expect(cubit.state.isResponding, isFalse);
      cubit.close();
    });

    test('empty and whitespace-only messages are ignored', () async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await cubit.sendMessage('');
      await cubit.sendMessage('   ');
      expect(cubit.state.messages, hasLength(1));
      cubit.close();
    });

    test('concurrent sends are prevented while responding', () async {
      final cubit = HealthAssistantCubit(repository: _SlowRepository());
      final first = cubit.sendMessage('chest pain');
      final second = cubit.sendMessage('bleeding');
      await Future.wait([first, second]);
      final userMessages = cubit.state.messages
          .where((m) => m.sender == ChatSender.user)
          .toList();
      expect(userMessages, hasLength(1));
      expect(userMessages.first.text, 'chest pain');
      cubit.close();
    });

    test('serious symptom responses set sosRecommended', () async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await cubit.sendMessage('I have chest pain');
      expect(cubit.state.sosRecommended, isTrue);
      cubit.close();
    });

    test('general questions do not set sosRecommended', () async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await cubit.sendMessage('What is first aid for a small cut?');
      expect(cubit.state.sosRecommended, isFalse);
      cubit.close();
    });

    test('failed send marks the message as error and retry recovers', () async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository(failFirst: true));
      await cubit.sendMessage('bleeding');
      expect(cubit.state.hasError, isTrue);
      expect(cubit.state.failedMessageId, isNotNull);
      expect(cubit.state.messages.any((m) => m.isError), isTrue);

      await cubit.retryLastMessage();
      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.messages.any((m) => m.isError), isFalse);
      expect(cubit.state.messages.last.sender, ChatSender.assistant);
      cubit.close();
    });

    test('clearConversation resets to just the welcome message', () async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await cubit.sendMessage('fall');
      cubit.clearConversation();
      expect(cubit.state.messages, hasLength(1));
      expect(cubit.state.messages.first.sender, ChatSender.assistant);
      expect(cubit.state.hasError, isFalse);
      cubit.close();
    });
  });
}

class _FakeRepository implements HealthAssistantRepository {
  _FakeRepository({this.failFirst = false});

  final bool failFirst;
  bool _firstCall = true;

    @override
    Future<HealthAssistantResponse> getResponse(
      String userMessage, {
      HealthContext? context,
    }) async {
      if (failFirst && _firstCall) {
        _firstCall = false;
        throw Exception('network error');
      }
      final text = userMessage.toLowerCase();
      final serious =
          text.contains('chest') ||
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

  class _SlowRepository implements HealthAssistantRepository {
    @override
    Future<HealthAssistantResponse> getResponse(
      String userMessage, {
      HealthContext? context,
    }) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return HealthAssistantResponse(text: 'ok');
    }
  }
