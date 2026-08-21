/// Deterministic emergency safety override for the AI Health Assistant.
///
/// The seven critical categories below MUST always recommend SOS, no matter
/// what an LLM (or any other engine) says. This is a hard safety net: it is
/// pure, offline, and unit-testable.
enum EmergencyCategory {
  unconscious(
    label: 'unconscious/unresponsive',
    keywords: [
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
      "won't wake up",
      'wont wake up',
      "can't wake",
      'cant wake',
    ],
    guidance:
        'If someone is unconscious or unresponsive, this is a medical '
        'emergency. Call emergency services immediately. Check whether they '
        'are breathing; if they are not breathing normally, begin CPR if you '
        'are trained. If they are breathing, place them on their side in the '
        'recovery position. Do not leave them alone and do not give them '
        'anything to eat or drink.',
  ),
  breathing(
    label: 'severe breathing difficulty',
    keywords: [
      "can't breathe",
      'cant breathe',
      'cannot breathe',
      'struggling to breathe',
      'difficulty breathing',
      'trouble breathing',
      'short of breath',
      'gasping',
      'choking',
      'not breathing',
      'stopped breathing',
      'breathless',
      'severe breathing',
    ],
    guidance:
        'Severe difficulty breathing is a medical emergency. I can\'t '
        'diagnose you, but if you are struggling to breathe, call emergency '
        'services immediately. Sit upright, try to stay calm, and loosen any '
        'tight clothing. Do not wait if your breathing is getting worse or '
        'you feel dizzy, confused, or your lips turn blue.',
  ),
  chestPain(
    label: 'chest pain',
    keywords: [
      'chest pain',
      'chest pressure',
      'chest tightness',
      'tightness in chest',
      'crushing chest',
      'heart attack',
      'cardiac',
      'pain in chest',
    ],
    guidance:
        'Chest pain can be a sign of a serious condition. I can\'t diagnose '
        'you, but chest pain — especially with shortness of breath, sweating, '
        'nausea, or pain spreading to your arm, back, or jaw — requires '
        'emergency care. Call emergency services now. Sit down, rest, and '
        'avoid any exertion while you wait.',
  ),
  bleeding(
    label: 'heavy bleeding',
    keywords: [
      'heavy bleeding',
      'severe bleeding',
      'bleeding heavily',
      'bleeding a lot',
      'uncontrolled bleeding',
      "won't stop bleeding",
      'wont stop bleeding',
      'profuse bleeding',
      'hemorrhage',
      'hemorrhaging',
      'bleeding out',
      'gushing blood',
    ],
    guidance:
        'Heavy or uncontrolled bleeding is a medical emergency. I can\'t '
        'provide a diagnosis, but please call emergency services right away. '
        'While waiting for help, apply firm, steady pressure to the wound '
        'with a clean cloth or bandage and keep the injured area raised if '
        'possible. Do not remove an object that is stuck in the wound.',
  ),
  fallHeadInjury(
    label: 'severe fall/head injury',
    keywords: [
      'hit my head',
      'hit his head',
      'hit her head',
      'hit their head',
      'head injury',
      'head trauma',
      'knocked out',
      'concussion',
      'fell and hit',
      'severe fall',
      'bad fall',
      'fell on my head',
      'fell on his head',
      'fell on her head',
      'bleeding from head',
    ],
    guidance:
        'A severe fall or head injury can be serious. I can\'t diagnose '
        'injuries, but call emergency services right away if the person hit '
        'their head, lost consciousness, is confused, drowsy, vomiting, or '
        'has severe pain. Do not move them unless they are in immediate '
        'danger, and watch for any change in consciousness while you wait.',
  ),
  seizure(
    label: 'seizure',
    keywords: [
      'seizure',
      'seizing',
      'convulsion',
      'convulsing',
      'epileptic',
      'epileptic fit',
      'having a fit',
      'shaking uncontrollably',
    ],
    guidance:
        'A seizure is a medical emergency. Call emergency services '
        'immediately. Protect the person from injury by clearing the area '
        'around them and cushioning their head. Do not hold them down and do '
        'not put anything in their mouth. Time the seizure, and once it '
        'stops, roll them onto their side if they are breathing.',
  ),
  stroke(
    label: 'stroke-like symptoms',
    keywords: [
      'stroke',
      'face drooping',
      'facial droop',
      'drooping',
      'slurred',
      'slurring',
      'one-sided weakness',
      'weakness on one side',
      'numb on one side',
      'sudden confusion',
      'vision loss',
      'worst headache',
      'severe headache',
    ],
    guidance:
        'These symptoms can be signs of a stroke, which is a medical '
        'emergency. Call emergency services immediately and note the time the '
        'symptoms started. Keep the person calm and lying down with their '
        'head slightly raised. Do not give them anything to eat, drink, or '
        'any medication.',
  );

  const EmergencyCategory({
    required this.label,
    required this.keywords,
    required this.guidance,
  });

  final String label;
  final List<String> keywords;
  final String guidance;
}
/// Matches user input against the seven critical emergency categories.
///
/// Used as a hard safety net on top of any response engine (LLM or local):
/// if [matchCategory] returns a category, the final response MUST recommend
/// SOS regardless of what the engine said.
class EmergencySafetyOverride {
  const EmergencySafetyOverride();

  /// Returns the first critical category matched by [userMessage], or null
  /// when the message does not describe one of the seven emergencies.
  EmergencyCategory? matchCategory(String userMessage) {
    final text = userMessage.toLowerCase();
    for (final category in EmergencyCategory.values) {
      if (category.keywords.any(text.contains)) return category;
    }
    return null;
  }

  /// Deterministic, safe guidance for a critical category. Used when the
  /// primary engine (LLM) is unavailable so the emergency response is never
  /// degraded by a network failure.
  String guidanceFor(EmergencyCategory category) => category.guidance;
}
