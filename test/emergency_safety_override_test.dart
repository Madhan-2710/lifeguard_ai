import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/health_assistant/data/datasources/emergency_safety_override.dart';

void main() {
  const override = EmergencySafetyOverride();

  group('EmergencySafetyOverride', () {
    test('matches all seven critical categories', () {
      expect(
        override.matchCategory('my friend is unconscious'),
        EmergencyCategory.unconscious,
      );
      expect(
        override.matchCategory("I can't breathe"),
        EmergencyCategory.breathing,
      );
      expect(
        override.matchCategory('I have chest pain'),
        EmergencyCategory.chestPain,
      );
      expect(
        override.matchCategory('I am bleeding heavily'),
        EmergencyCategory.bleeding,
      );
      expect(
        override.matchCategory('I fell and hit my head'),
        EmergencyCategory.fallHeadInjury,
      );
      expect(
        override.matchCategory('he is having a seizure'),
        EmergencyCategory.seizure,
      );
      expect(
        override.matchCategory('her face is drooping and speech is slurred'),
        EmergencyCategory.stroke,
      );
    });

    test('matching is case-insensitive', () {
      expect(
        override.matchCategory('CHEST PAIN'),
        EmergencyCategory.chestPain,
      );
    });

    test('returns null for non-emergency input', () {
      expect(override.matchCategory('how do I treat a small cut?'), isNull);
      expect(override.matchCategory('tell me a joke'), isNull);
    });

    test('guidance is non-empty and mentions emergency services', () {
      for (final category in EmergencyCategory.values) {
        final guidance = override.guidanceFor(category);
        expect(guidance, isNotEmpty, reason: '${category.label} guidance');
        expect(
          guidance.toLowerCase(),
          contains('emergency'),
          reason: '${category.label} guidance',
        );
      }
    });

    test('guidance never claims safety, diagnoses, or prescribes', () {
      for (final category in EmergencyCategory.values) {
        final text = override.guidanceFor(category).toLowerCase();
        expect(text, isNot(contains('you are safe')));
        expect(text, isNot(contains('i diagnose')));
        expect(text, isNot(contains('i prescribe')));
        expect(text, isNot(contains('take this medication')));
      }
    });
  });
}
