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

    test('responses never claim safety, diagnose, or prescribe', () async {
      final responses = await Future.wait([
        dataSource.getResponse('fall'),
        dataSource.getResponse('bleeding'),
        dataSource.getResponse('breathing'),
        dataSource.getResponse('chest pain'),
        dataSource.getResponse('unconscious'),
        dataSource.getResponse('first aid'),
      ]);
      for (final r in responses) {
        final text = r.text.toLowerCase();
        // Never claims the user is medically safe.
        expect(text, isNot(contains('you are safe')));
        expect(text, isNot(contains('you are medically safe')));
        // Never claims to diagnose or prescribe (it explicitly declines to).
        expect(text, isNot(contains('i diagnose')));
        expect(text, isNot(contains('i prescribe')));
        expect(text, isNot(contains('take this medication')));
      }
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
