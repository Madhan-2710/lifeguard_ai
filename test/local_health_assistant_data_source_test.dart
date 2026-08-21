import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/health_assistant/data/datasources/local_health_assistant_data_source.dart';

void main() {
  const dataSource = LocalHealthAssistantDataSource();

  group('LocalHealthAssistantDataSource', () {
    test('fall keywords recommend SOS', () async {
      final response = await dataSource.getResponse('I fell down the stairs');
      expect(response.sosRecommended, isTrue);
      expect(response.text, isNotEmpty);
    });

    test('bleeding keywords recommend SOS', () async {
      final response = await dataSource.getResponse('I am bleeding a lot');
      expect(response.sosRecommended, isTrue);
      expect(response.text, isNotEmpty);
    });

    test('breathing difficulty recommends SOS', () async {
      final response = await dataSource.getResponse("I can't breathe");
      expect(response.sosRecommended, isTrue);
      expect(response.text, isNotEmpty);
    });

    test('chest pain recommends SOS', () async {
      final response = await dataSource.getResponse('I have chest pain');
      expect(response.sosRecommended, isTrue);
      expect(response.text, isNotEmpty);
    });

    test('unconscious recommends SOS', () async {
      final response = await dataSource.getResponse('my friend is unconscious');
      expect(response.sosRecommended, isTrue);
      expect(response.text, isNotEmpty);
    });

    test('general first aid questions do not recommend SOS', () async {
      final response = await dataSource.getResponse('how do I treat a small cut?');
      expect(response.sosRecommended, isFalse);
      expect(response.text, isNotEmpty);
    });

    test('unknown input falls back to general guidance', () async {
      final response = await dataSource.getResponse('tell me a joke');
      expect(response.sosRecommended, isFalse);
      expect(response.text, isNotEmpty);
    });

    test('responses never claim safety, diagnose, or prescribe Rx-only meds',
        () async {
      final responses = await Future.wait([
        dataSource.getResponse('fall'),
        dataSource.getResponse('bleeding'),
        dataSource.getResponse('breathing'),
        dataSource.getResponse('chest pain'),
        dataSource.getResponse('unconscious'),
        dataSource.getResponse('first aid'),
        dataSource.getResponse('headache'),
        dataSource.getResponse('fever'),
        dataSource.getResponse('cold'),
        dataSource.getResponse('cough'),
        dataSource.getResponse('sore throat'),
        dataSource.getResponse('allergy'),
        dataSource.getResponse('heartburn'),
        dataSource.getResponse('nausea'),
        dataSource.getResponse('constipation'),
        dataSource.getResponse('diarrhea'),
        dataSource.getResponse('back pain'),
      ]);
      for (final r in responses) {
        final text = r.text.toLowerCase();
        // Never claims the user is medically safe.
        expect(text, isNot(contains('you are safe')));
        expect(text, isNot(contains('you are medically safe')));
        // Never claims to diagnose or prescribe prescription-only medicine.
        expect(text, isNot(contains('i diagnose')));
        expect(text, isNot(contains('i prescribe')));
        expect(text, isNot(contains('take this medication')));
        expect(text, isNot(contains('antibiotic')));
      }
    });

    test('medication questions suggest OTC options with precautions', () async {
      final responses = await Future.wait([
        dataSource.getResponse('what medicine can I take for a headache?'),
        dataSource.getResponse('I have a fever, what should I take?'),
        dataSource.getResponse('medicine for a cold'),
        dataSource.getResponse('what helps a cough?'),
        dataSource.getResponse('sore throat medicine'),
        dataSource.getResponse('allergy medicine'),
        dataSource.getResponse('heartburn relief'),
        dataSource.getResponse('nausea medicine'),
        dataSource.getResponse('constipation relief'),
        dataSource.getResponse('diarrhea medicine'),
        dataSource.getResponse('pain relief for my back'),
      ]);
      for (final r in responses) {
        final text = r.text.toLowerCase();
        expect(r.sosRecommended, isFalse);
        // Structured guidance with all five sections.
        expect(text, contains('what you can do now'));
        expect(text, contains('possible otc medicine options'));
        expect(text, contains('important precautions'));
        expect(text, contains('when to see a doctor'));
        expect(text, contains('emergency warning signs'));
        // Always defers to a doctor or pharmacist.
        expect(text, contains('pharmacist'));
      }
    });

    test('medication questions never guarantee safety or prescribe Rx-only meds',
        () async {
      final responses = await Future.wait([
        dataSource.getResponse('what medicine can I take for a headache?'),
        dataSource.getResponse('I have a fever, what should I take?'),
        dataSource.getResponse('medicine for a cold'),
        dataSource.getResponse('what helps a cough?'),
        dataSource.getResponse('sore throat medicine'),
        dataSource.getResponse('allergy medicine'),
        dataSource.getResponse('heartburn relief'),
        dataSource.getResponse('nausea medicine'),
        dataSource.getResponse('constipation relief'),
        dataSource.getResponse('diarrhea medicine'),
        dataSource.getResponse('pain relief for my back'),
      ]);
      for (final r in responses) {
        final text = r.text.toLowerCase();
        expect(text, isNot(contains('i prescribe')));
        expect(text, isNot(contains('take this medication')));
        expect(text, isNot(contains('antibiotic')));
        expect(text, isNot(contains('this medicine is safe for you')));
      }
    });

    test('emergency symptoms still recommend SOS even when asking about medicine',
        () async {
      final responses = await Future.wait([
        dataSource.getResponse('chest pain, what medicine should I take?'),
        dataSource.getResponse("I can't breathe, is there a medicine?"),
        dataSource.getResponse('bleeding a lot, what should I take?'),
        dataSource.getResponse('my friend is unconscious, any medicine?'),
      ]);
      for (final r in responses) {
        expect(r.sosRecommended, isTrue);
        expect(r.text.toLowerCase(), contains('emergency'));
      }
    });

    test('heartburn is not treated as a heart emergency', () async {
      final response = await dataSource.getResponse('I have heartburn');
      expect(response.sosRecommended, isFalse);
      expect(response.text.toLowerCase(), contains('antacid'));
    });

    test('serious responses recommend emergency assistance', () async {
      final responses = await Future.wait([
        dataSource.getResponse('fall'),
        dataSource.getResponse('bleeding'),
        dataSource.getResponse('breathing'),
        dataSource.getResponse('chest pain'),
        dataSource.getResponse('unconscious'),
      ]);
      for (final r in responses) {
        expect(r.sosRecommended, isTrue);
        expect(r.text.toLowerCase(), contains('emergency'));
      }
    });
  });
}
