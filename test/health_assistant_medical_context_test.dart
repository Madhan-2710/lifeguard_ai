import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/health_assistant/data/datasources/local_health_assistant_data_source.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/health_context.dart';

void main() {
  const dataSource = LocalHealthAssistantDataSource();

  group('LocalHealthAssistantDataSource with medical context', () {
    test('allergy-aware: ibuprofen allergy is never casually suggested',
        () async {
      const context = HealthContext(allergies: ['ibuprofen']);
      final response = await dataSource.getResponse(
        'What can I take for a headache?',
        context: context,
      );

      final text = response.text.toLowerCase();
      // The saved profile allergy is surfaced.
      expect(text, contains('saved profile shows an allergy'));
      expect(text, contains('ibuprofen'));
      // The conflicting medicine is not suggested as an option.
      expect(text, isNot(contains('possible otc medicine options: acetaminophen (paracetamol), ibuprofen')));
      expect(text, isNot(contains('acetaminophen (paracetamol) or ibuprofen')));
      // Doctor/pharmacist confirmation is requested.
      expect(text, contains('doctor or pharmacist'));
      expect(text, contains('avoid medicines containing'));
      expect(response.sosRecommended, isFalse);
    });

    test('allergy-aware: safe alternative is still offered', () async {
      const context = HealthContext(allergies: ['ibuprofen']);
      final response = await dataSource.getResponse(
        'What can I take for a headache?',
        context: context,
      );

      final text = response.text.toLowerCase();
      // Acetaminophen does not conflict with the ibuprofen allergy.
      expect(text, contains('acetaminophen (paracetamol)'));
    });

    test('current-medicine-aware: existing medicines raise caution', () async {
      const context = HealthContext(currentMedicines: ['Metformin', 'Amlodipine']);
      final response = await dataSource.getResponse(
        'What can I take for a headache?',
        context: context,
      );

      final text = response.text.toLowerCase();
      expect(text, contains('currently take: metformin, amlodipine'));
      expect(text, contains('cannot verify interactions'));
      expect(text, contains('doctor or pharmacist'));
      // Never claims there is no interaction.
      expect(text, isNot(contains('no interaction')));
      expect(text, isNot(contains('safe to take together')));
    });

    test('chronic-condition-aware: conditions raise caution level', () async {
      const context = HealthContext(chronicConditions: ['diabetes', 'hypertension']);
      final response = await dataSource.getResponse(
        'What can I take for a cold?',
        context: context,
      );

      final text = response.text.toLowerCase();
      expect(text, contains('saved profile lists: diabetes, hypertension'));
      expect(text, contains('may matter when choosing medicines'));
      expect(text, contains('doctor or pharmacist'));
    });

    test('emergency symptoms still trigger SOS with profile context', () async {
      // Asthma in the profile must NEVER suppress emergency escalation.
      const context = HealthContext(
        chronicConditions: ['asthma'],
        allergies: ['penicillin'],
        currentMedicines: ['Salbutamol'],
      );
      final response = await dataSource.getResponse(
        'I am having severe breathing difficulty',
        context: context,
      );

      expect(response.sosRecommended, isTrue);
      expect(response.text.toLowerCase(), contains('emergency'));
    });

    test('emergency responses are not modified by profile context', () async {
      const context = HealthContext(allergies: ['ibuprofen']);
      final withContext = await dataSource.getResponse(
        'I have chest pain',
        context: context,
      );
      final withoutContext = await dataSource.getResponse('I have chest pain');

      expect(withContext.sosRecommended, isTrue);
      expect(withContext.text, withoutContext.text);
    });

    test('existing behavior still works without profile context', () async {
      final response = await dataSource.getResponse(
        'What can I take for a headache?',
      );

      final text = response.text.toLowerCase();
      expect(text, contains('what you can do now'));
      expect(text, contains('possible otc medicine options'));
      expect(text, contains('important precautions'));
      expect(text, contains('when to see a doctor'));
      expect(text, contains('emergency warning signs'));
      expect(text, contains('pharmacist'));
      // Without a profile, ibuprofen is a normal general suggestion.
      expect(text, contains('ibuprofen'));
      expect(response.sosRecommended, isFalse);
    });

    test('empty context behaves exactly like no context', () async {
      const empty = HealthContext();
      final withEmpty = await dataSource.getResponse(
        'What can I take for a headache?',
        context: empty,
      );
      final without = await dataSource.getResponse(
        'What can I take for a headache?',
      );

      expect(withEmpty.text, without.text);
    });

    test('allergy-aware: NSAID category allergy blocks ibuprofen', () async {
      const context = HealthContext(allergies: ['NSAIDs']);
      final response = await dataSource.getResponse(
        'What can I take for a headache?',
        context: context,
      );

      final text = response.text.toLowerCase();
      expect(text, contains('saved profile shows an allergy'));
      expect(text, isNot(contains('acetaminophen (paracetamol) or ibuprofen')));
    });
  });
}
