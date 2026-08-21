import '../../domain/entities/health_assistant_response.dart';
import 'health_assistant_data_source.dart';

/// Local, offline-first response engine for the AI Health Assistant.
///
/// Matches user input against known symptom topics and returns safe,
/// non-diagnostic first-aid guidance. Serious symptoms always set
/// [HealthAssistantResponse.sosRecommended] so the UI can offer the
/// emergency SOS action.
///
/// Safety rules enforced here:
/// - never diagnoses a condition
/// - never prescribes medication
/// - never claims the user is medically safe
/// - serious symptoms recommend emergency/professional assistance
///
/// This engine intentionally contains no LLM, network, or API-key code.
class LocalHealthAssistantDataSource implements HealthAssistantDataSource {
  const LocalHealthAssistantDataSource();

  static const List<String> _unconsciousKeywords = [
    'unconscious',
    'unresponsive',
    'passed out',
    'blacked out',
    'faint',
    'fainted',
    'fainting',
    'not responding',
    'no response',
    'coma',
  ];

  static const List<String> _chestPainKeywords = [
    'chest',
    'heart',
    'cardiac',
    'palpitation',
    'tightness in chest',
  ];

  static const List<String> _breathingKeywords = [
    'breath',
    'short of breath',
    'wheeze',
    'choke',
    'choking',
    "can't breathe",
    'cant breathe',
  ];

  static const List<String> _bleedingKeywords = [
    'bleed',
    'bleeding',
    'blood loss',
    'gash',
    'wound',
    'hemorrhage',
  ];

  static const List<String> _fallKeywords = [
    'fall',
    'fell',
    'tripped',
    'slipped',
    'collapse',
    'collapsed',
  ];

  @override
  Future<HealthAssistantResponse> getResponse(String userMessage) async {
    final text = userMessage.toLowerCase();

    if (_matchesAny(text, _unconsciousKeywords)) return _unconscious;
    if (_matchesAny(text, _chestPainKeywords)) return _chestPain;
    if (_matchesAny(text, _breathingKeywords)) return _breathing;
    if (_matchesAny(text, _bleedingKeywords)) return _bleeding;
    if (_matchesAny(text, _fallKeywords)) return _fall;
    return _general;
  }

  bool _matchesAny(String text, List<String> keywords) =>
      keywords.any(text.contains);

  static const HealthAssistantResponse _unconscious = HealthAssistantResponse(
    text: 'If someone is unconscious or unresponsive, this is a medical '
        'emergency. Call emergency services immediately. Check whether they '
        'are breathing; if they are not breathing normally, begin CPR if you '
        'are trained. If they are breathing, place them on their side in the '
        'recovery position. Do not leave them alone and do not give them '
        'anything to eat or drink.',
    sosRecommended: true,
  );

  static const HealthAssistantResponse _chestPain = HealthAssistantResponse(
    text: 'Chest pain can be a sign of a serious condition. I can\'t diagnose '
        'you, but chest pain — especially with shortness of breath, sweating, '
        'nausea, or pain spreading to your arm, back, or jaw — requires '
        'emergency care. Call emergency services now. Sit down, rest, and '
        'avoid any exertion while you wait.',
    sosRecommended: true,
  );

  static const HealthAssistantResponse _breathing = HealthAssistantResponse(
    text: 'Difficulty breathing can be a medical emergency. I can\'t diagnose '
        'you, but if you are struggling to breathe, call emergency services '
        'immediately. Sit upright, try to stay calm, and loosen any tight '
        'clothing. Do not wait if your breathing is getting worse or you feel '
        'dizzy, confused, or your lips turn blue.',
    sosRecommended: true,
  );

  static const HealthAssistantResponse _bleeding = HealthAssistantResponse(
    text: 'Heavy or uncontrolled bleeding is a medical emergency. I can\'t '
        'provide a diagnosis, but please call emergency services right away. '
        'While waiting for help, apply firm, steady pressure to the wound '
        'with a clean cloth or bandage and keep the injured area raised if '
        'possible. Do not remove an object that is stuck in the wound. For a '
        'minor cut, clean it gently with water, apply pressure, and cover it '
        'with a sterile dressing.',
    sosRecommended: true,
  );

  static const HealthAssistantResponse _fall = HealthAssistantResponse(
    text: 'I\'m sorry to hear you\'ve had a fall. I can\'t diagnose injuries, '
        'but falls can cause serious harm. If you hit your head, can\'t get '
        'up, have severe pain, or feel confused or dizzy, call emergency '
        'services right away. If you\'re able, ask someone nearby for help '
        'and avoid moving suddenly. For a minor fall with no pain or injury, '
        'rest and monitor how you feel.',
    sosRecommended: true,
  );

  static const HealthAssistantResponse _general = HealthAssistantResponse(
    text: 'I can offer general first aid information, but I\'m not a doctor '
        'and I can\'t diagnose conditions or prescribe medication. For a '
        'minor issue like a small cut, clean it with water, apply gentle '
        'pressure, and cover it with a sterile dressing. If your symptoms are '
        'severe, getting worse, or you\'re unsure what to do, contact a '
        'healthcare professional or call emergency services. You can also ask '
        'me about falls, bleeding, breathing difficulty, chest pain, or '
        'unconsciousness.',
    sosRecommended: false,
  );
}
