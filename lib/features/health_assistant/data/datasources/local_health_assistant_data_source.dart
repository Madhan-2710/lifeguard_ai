import '../../domain/entities/health_assistant_response.dart';
import '../../domain/entities/health_context.dart';
import 'health_assistant_data_source.dart';

/// Local, offline-first response engine for the AI Health Assistant.
///
/// Matches user input against known symptom topics and returns safe,
/// non-diagnostic guidance. Serious symptoms always set
/// [HealthAssistantResponse.sosRecommended] so the UI can offer the
/// emergency SOS action.
///
/// When the user asks what medicine may help, the engine may suggest common
/// non-prescription (OTC) medicines or categories generally used for the
/// reported symptom, always with precautions and when-to-see-a-doctor
/// guidance. It never prescribes prescription-only medicines, never
/// diagnoses, and never claims the user is medically safe.
///
/// When a [HealthContext] (built from the authenticated user's saved medical
/// profile) is provided, the engine uses it as SAFE CONTEXT:
/// - medicines the user is allergic to are never casually suggested
/// - current medicines and chronic conditions raise cautious wording
/// - emergency responses are never modified and always recommend SOS
///
/// Safety rules enforced here:
/// - never diagnoses a condition
/// - never prescribes prescription-only medication
/// - never claims the user is medically safe
/// - OTC suggestions always include precautions and doctor/pharmacist advice
/// - serious symptoms recommend emergency/professional assistance
/// - medical-profile context never suppresses emergency escalation
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
    'chest pain',
    'chest pressure',
    'chest tightness',
    'tightness in chest',
    'crushing chest',
    'heart attack',
    'cardiac',
    'palpitation',
    'pain in chest',
    'heart pain',
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

  // Common symptoms where OTC medicine guidance may be appropriate.
  static const List<String> _headacheKeywords = [
    'headache',
    'head ache',
    'migraine',
    'head pain',
    'head hurts',
  ];

  static const List<String> _feverKeywords = [
    'fever',
    'high temperature',
    'temperature',
    'chills',
  ];

  static const List<String> _coldFluKeywords = [
    'common cold',
    'have a cold',
    'caught a cold',
    'got a cold',
    'for a cold',
    'cold and flu',
    'cold symptoms',
    'flu',
    'influenza',
    'runny nose',
    'stuffy nose',
    'blocked nose',
    'congestion',
    'sneezing',
    'sneez',
  ];

  static const List<String> _coughKeywords = [
    'cough',
    'coughing',
  ];

  static const List<String> _soreThroatKeywords = [
    'sore throat',
    'throat pain',
    'scratchy throat',
    'throat hurts',
  ];

  static const List<String> _allergyKeywords = [
    'allergy',
    'allergic',
    'hay fever',
    'itchy eyes',
    'hives',
  ];

  static const List<String> _heartburnKeywords = [
    'heartburn',
    'indigestion',
    'acid reflux',
    'upset stomach',
    'stomach ache',
    'stomach pain',
    'tummy ache',
    'abdominal pain',
    'belly ache',
  ];

  static const List<String> _nauseaKeywords = [
    'nausea',
    'nauseous',
    'nauseated',
    'queasy',
    'vomit',
    'vomiting',
    'throwing up',
  ];

  static const List<String> _constipationKeywords = [
    'constipation',
    'constipated',
    'hard stool',
    'hard stools',
  ];

  static const List<String> _diarrheaKeywords = [
    'diarrhea',
    'diarrhoea',
    'loose stool',
    'loose stools',
    'runny stool',
  ];

  static const List<String> _painKeywords = [
    'pain',
    'ache',
    'aching',
    'sore',
    'hurt',
    'hurts',
    'sprain',
    'strain',
    'injury',
  ];

  @override
  Future<HealthAssistantResponse> getResponse(
    String userMessage, {
    HealthContext? context,
  }) async {
    final text = userMessage.toLowerCase();
    final ctx = context ?? const HealthContext();

    // Critical emergencies are always handled first and always recommend SOS.
    if (_matchesAny(text, _unconsciousKeywords)) return _unconscious;
    if (_matchesAny(text, _chestPainKeywords)) return _chestPain;
    if (_matchesAny(text, _breathingKeywords)) return _breathing;
    if (_matchesAny(text, _bleedingKeywords)) return _bleeding;
    if (_matchesAny(text, _fallKeywords)) return _fall;

    // Common symptoms where OTC medicine guidance may be appropriate.
    if (_matchesAny(text, _headacheKeywords)) {
      return _medicationResponse(_headacheGuidance, ctx);
    }
    if (_matchesAny(text, _feverKeywords)) {
      return _medicationResponse(_feverGuidance, ctx);
    }
    if (_matchesAny(text, _coldFluKeywords)) {
      return _medicationResponse(_coldFluGuidance, ctx);
    }
    if (_matchesAny(text, _coughKeywords)) {
      return _medicationResponse(_coughGuidance, ctx);
    }
    if (_matchesAny(text, _soreThroatKeywords)) {
      return _medicationResponse(_soreThroatGuidance, ctx);
    }
    if (_matchesAny(text, _allergyKeywords)) {
      return _medicationResponse(_allergyGuidance, ctx);
    }
    if (_matchesAny(text, _heartburnKeywords)) {
      return _medicationResponse(_heartburnGuidance, ctx);
    }
    if (_matchesAny(text, _nauseaKeywords)) {
      return _medicationResponse(_nauseaGuidance, ctx);
    }
    if (_matchesAny(text, _constipationKeywords)) {
      return _medicationResponse(_constipationGuidance, ctx);
    }
    if (_matchesAny(text, _diarrheaKeywords)) {
      return _medicationResponse(_diarrheaGuidance, ctx);
    }
    if (_matchesAny(text, _painKeywords)) {
      return _medicationResponse(_painGuidance, ctx);
    }

    return _general;
  }

  bool _matchesAny(String text, List<String> keywords) =>
      keywords.any(text.contains);
  // ---- Emergency responses (never modified by profile context) ----

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
  // ---- Structured OTC guidance per symptom category ----

  static const _MedicationGuidance _headacheGuidance = _MedicationGuidance(
    selfCare: 'Rest in a quiet, dim room, drink water, and apply a cool or '
        'warm compress to your head or neck. Avoid screens, caffeine, and '
        'alcohol if they seem to trigger it.',
    otcOptions: [
      'acetaminophen (paracetamol)',
      'ibuprofen',
    ],
    precautions: [
      'Do not exceed the label dose, and avoid using pain relievers more '
          'than a few days per week (this can cause rebound headaches).',
      'Avoid ibuprofen or aspirin if you have stomach ulcers, kidney '
          'problems, or are pregnant unless a doctor says it\'s OK.',
      'Never give aspirin to anyone under 16.',
    ],
    whenToSeeDoctor: 'If headaches are frequent, severe, or getting worse, '
        'or if you need pain relievers more than twice a week.',
    emergencySigns: 'A sudden, severe "worst-ever" headache, or a headache '
        'with fever and stiff neck, confusion, weakness, numbness, vision '
        'changes, or after a head injury — call emergency services right '
        'away.',
  );

  static const _MedicationGuidance _feverGuidance = _MedicationGuidance(
    selfCare: 'Rest, drink plenty of fluids, and dress lightly. A lukewarm '
        '(not cold) sponge bath can help you feel more comfortable.',
    otcOptions: [
      'acetaminophen (paracetamol)',
      'ibuprofen',
    ],
    precautions: [
      'Do not exceed the label dose and do not combine multiple products '
          'containing the same ingredient.',
      'Avoid ibuprofen or aspirin if you have stomach ulcers, kidney '
          'problems, or are pregnant unless a doctor says it\'s OK.',
      'Never give aspirin to anyone under 16.',
    ],
    whenToSeeDoctor: 'If a fever lasts more than 3 days, is very high, or '
        'you have a weakened immune system, a chronic condition, or are '
        'pregnant.',
    emergencySigns: 'Fever with a stiff neck, severe headache, confusion, '
        'difficulty breathing, a rash that doesn\'t fade, or seizures — call '
        'emergency services right away.',
  );

  static const _MedicationGuidance _coldFluGuidance = _MedicationGuidance(
    selfCare: 'Rest, drink warm fluids, and use a humidifier or steam to '
        'ease congestion. Saline nasal spray or rinses can help a stuffy '
        'nose.',
    otcOptions: [
      'decongestants (e.g., pseudoephedrine or phenylephrine) for a blocked '
          'nose',
      'cough suppressants or expectorants for a cough',
      'acetaminophen or ibuprofen for aches or fever',
    ],
    precautions: [
      'Avoid taking multiple cold products at once — many contain the same '
          'ingredients (e.g., acetaminophen) and doubling up can be '
          'dangerous.',
      'Decongestants can raise blood pressure, so check with a pharmacist '
          'if you have heart problems or high blood pressure.',
      'Do not give cough and cold medicines to children under 6 without '
          'professional advice.',
    ],
    whenToSeeDoctor: 'If symptoms last more than 10 days, get worse, or you '
        'have a chronic condition (asthma, diabetes, heart disease) or are '
        'pregnant.',
    emergencySigns: 'Difficulty breathing, chest pain, confusion, or a high '
        'fever that won\'t come down — call emergency services right away.',
  );

  static const _MedicationGuidance _coughGuidance = _MedicationGuidance(
    selfCare: 'Drink warm fluids like honey and lemon in warm water (not '
        'for babies under 1), rest, and use steam from a hot shower to '
        'soothe your airways.',
    otcOptions: [
      'cough suppressants (e.g., dextromethorphan) for a dry, tickly cough',
      'expectorants (e.g., guaifenesin) for a chesty cough',
    ],
    precautions: [
      'Do not give cough medicines to children under 6 without professional '
          'advice.',
      'Avoid combining multiple cough products.',
      'If you have asthma, COPD, or other lung conditions, check with a '
          'pharmacist or doctor first.',
    ],
    whenToSeeDoctor: 'If a cough lasts more than 3 weeks, brings up blood, '
        'or is accompanied by fever, weight loss, or shortness of breath.',
    emergencySigns: 'Coughing up blood, difficulty breathing, chest pain, '
        'or lips turning blue — call emergency services right away.',
  );
  static const _MedicationGuidance _soreThroatGuidance = _MedicationGuidance(
    selfCare: 'Drink warm fluids, gargle with warm salt water, and suck on '
        'ice chips or lozenges to soothe the throat. Rest your voice.',
    otcOptions: [
      'throat lozenges or sprays with local anesthetics (e.g., benzocaine)',
      'acetaminophen or ibuprofen for pain',
    ],
    precautions: [
      'Do not exceed the label dose of lozenges or sprays.',
      'Avoid ibuprofen or aspirin if you have stomach ulcers, kidney '
          'problems, or are pregnant unless a doctor says it\'s OK.',
      'Never give aspirin to anyone under 16.',
    ],
    whenToSeeDoctor: 'If a sore throat lasts more than a week, is very '
        'painful, or comes with a high fever, swollen glands, or white '
        'patches — a bacterial infection may need evaluation.',
    emergencySigns: 'Difficulty swallowing or breathing, drooling, muffled '
        'voice, or a swollen throat — call emergency services right away.',
  );

  static const _MedicationGuidance _allergyGuidance = _MedicationGuidance(
    selfCare: 'Avoid the trigger where possible, rinse your eyes with clean '
        'water, and use a saline nasal rinse to flush allergens.',
    otcOptions: [
      'non-drowsy antihistamines (e.g., cetirizine, loratadine, '
          'fexofenadine)',
      'antihistamine eye drops for itchy eyes',
    ],
    precautions: [
      'Some antihistamines (e.g., diphenhydramine) cause drowsiness — avoid '
          'driving or operating machinery.',
      'Check with a pharmacist if you have liver or kidney problems, are '
          'pregnant, or take other medicines.',
    ],
    whenToSeeDoctor: 'If symptoms are severe, don\'t improve with OTC '
        'options, or you have asthma alongside allergies.',
    emergencySigns: 'Swelling of the face, lips, or tongue, difficulty '
        'breathing, wheezing, or a widespread rash after exposure — call '
        'emergency services right away.',
  );

  static const _MedicationGuidance _heartburnGuidance = _MedicationGuidance(
    selfCare: 'Eat smaller meals, avoid lying down for 2-3 hours after '
        'eating, and avoid spicy, fatty, or acidic foods, caffeine, and '
        'alcohol.',
    otcOptions: [
      'antacids (e.g., calcium carbonate, magnesium hydroxide) for quick '
          'relief',
      'H2 blockers (e.g., famotidine) or proton pump inhibitors (e.g., '
          'omeprazole) for longer-lasting relief',
    ],
    precautions: [
      'Do not take antacids at the same time as other medicines (they can '
          'affect absorption).',
      'Long-term use of PPIs should be reviewed by a doctor.',
      'Check with a pharmacist if you have kidney problems or take other '
          'medicines.',
    ],
    whenToSeeDoctor: 'If heartburn happens more than twice a week, lasts '
        'more than 2 weeks despite treatment, or you have difficulty '
        'swallowing or unintentional weight loss.',
    emergencySigns: 'Chest pain that spreads to your arm, neck, or jaw, or '
        'comes with sweating, shortness of breath, or nausea — call '
        'emergency services right away.',
  );

  static const _MedicationGuidance _nauseaGuidance = _MedicationGuidance(
    selfCare: 'Sip clear fluids slowly (water, ginger tea, or oral '
        'rehydration solution), eat small bland meals like crackers or '
        'toast, and rest. Avoid strong smells, greasy, or spicy food.',
    otcOptions: [
      'dimenhydrinate (for motion sickness)',
      'antacids if the nausea is linked to indigestion',
      'ginger products may help mild nausea',
    ],
    precautions: [
      'Do not take anti-nausea medicines if you have severe abdominal pain '
          'without checking with a pharmacist.',
      'Check with a pharmacist if you are pregnant or take other medicines.',
    ],
    whenToSeeDoctor: 'If nausea lasts more than 2 days, you can\'t keep '
        'fluids down, or you have signs of dehydration.',
    emergencySigns: 'Nausea with severe abdominal pain, chest pain, '
        'confusion, stiff neck, or vomiting blood — call emergency services '
        'right away.',
  );
  static const _MedicationGuidance _constipationGuidance = _MedicationGuidance(
    selfCare: 'Drink more water, increase fiber gradually (fruits, '
        'vegetables, whole grains), and stay active. Try to respond to the '
        'urge to go.',
    otcOptions: [
      'bulk-forming laxatives (e.g., psyllium)',
      'stool softeners (e.g., docusate)',
      'osmotic laxatives (e.g., polyethylene glycol)',
    ],
    precautions: [
      'Drink plenty of water with fiber or bulk-forming laxatives.',
      'Do not use stimulant laxatives regularly — they can cause '
          'dependence.',
      'Check with a pharmacist if you are pregnant or take other medicines.',
    ],
    whenToSeeDoctor: 'If constipation lasts more than 3 weeks, is severe, '
        'or comes with abdominal pain, blood in the stool, or unexplained '
        'weight loss.',
    emergencySigns: 'Severe abdominal pain, vomiting, inability to pass '
        'gas, or blood in the stool — call emergency services right away.',
  );

  static const _MedicationGuidance _diarrheaGuidance = _MedicationGuidance(
    selfCare: 'The most important thing is to replace fluids — sip water, '
        'oral rehydration solution (ORS), or clear broths frequently. Eat '
        'bland foods like rice, bananas, and toast.',
    otcOptions: [
      'oral rehydration salts (ORS) — the safest first choice',
      'loperamide for mild, non-fever diarrhea in adults',
    ],
    precautions: [
      'Do not use loperamide if you have a fever, blood in the stool, or '
          'think the cause may be bacterial — this can make it worse.',
      'Do not give loperamide to children without professional advice.',
    ],
    whenToSeeDoctor: 'If diarrhea lasts more than 2 days (or more than 24 '
        'hours in a child), or you have a high fever, blood in the stool, '
        'or signs of dehydration.',
    emergencySigns: 'Severe dehydration (dizziness, dark urine, dry mouth, '
        'little or no urination), blood in the stool, or severe abdominal '
        'pain — seek medical care right away.',
  );

  static const _MedicationGuidance _painGuidance = _MedicationGuidance(
    selfCare: 'Rest the area, apply ice for the first 24-48 hours (15-20 '
        'minutes at a time, wrapped in a cloth), then heat. Elevate the '
        'area if possible.',
    otcOptions: [
      'acetaminophen (paracetamol) or ibuprofen for pain and inflammation',
      'topical creams or gels (e.g., menthol, diclofenac gel)',
    ],
    precautions: [
      'Do not exceed the label dose.',
      'Avoid ibuprofen or aspirin if you have stomach ulcers, kidney '
          'problems, or are pregnant unless a doctor says it\'s OK.',
      'Never give aspirin to anyone under 16.',
    ],
    whenToSeeDoctor: 'If pain is severe, doesn\'t improve after a few days, '
        'or you can\'t put weight on the area.',
    emergencySigns: 'Pain with deformity, numbness, tingling, or inability '
        'to move the limb, or pain after a serious injury — seek medical '
        'care right away.',
  );
  // ---- Context-aware medication response builder ----

  /// Builds a medication-guidance response, using the saved medical profile
  /// as SAFE CONTEXT:
  /// - OTC options that conflict with a listed allergy are removed
  /// - current medicines and chronic conditions add cautious wording
  /// - the response never guarantees safety or interaction compatibility
  HealthAssistantResponse _medicationResponse(
    _MedicationGuidance guidance,
    HealthContext context,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('1. What you can do now: ${guidance.selfCare}');

    final conflictingAllergies = <String>{};
    final safeOptions = <String>[];
    for (final option in guidance.otcOptions) {
      final conflicts = context.allergies
          .where((a) => _allergyMatchesOption(a, option))
          .toList();
      if (conflicts.isEmpty) {
        safeOptions.add(option);
      } else {
        conflictingAllergies.addAll(conflicts);
      }
    }

    if (safeOptions.isEmpty) {
      buffer.writeln(
        '2. Possible OTC medicine options: The common OTC options for this '
        'symptom may conflict with allergies in your saved medical profile. '
        'Do not take any of them without confirming with a doctor or '
        'pharmacist first.',
      );
    } else {
      buffer.writeln(
        '2. Possible OTC medicine options: ${safeOptions.join(', ')}. These '
        'are general suggestions — check with a pharmacist that they are '
        'right for you.',
      );
    }

    buffer.writeln(
      '3. Important precautions: ${guidance.precautions.join(' ')}',
    );
    buffer.writeln('4. When to see a doctor: ${guidance.whenToSeeDoctor}');
    buffer.writeln('5. Emergency warning signs: ${guidance.emergencySigns}');

    if (conflictingAllergies.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(
        'Your saved profile shows an allergy to: '
        '${conflictingAllergies.join(', ')}. Avoid medicines containing '
        'these. Please confirm with a doctor or pharmacist before taking '
        'anything.',
      );
    }

    if (context.hasCurrentMedicines) {
      buffer.writeln();
      buffer.writeln(
        'Your saved profile shows you currently take: '
        '${context.currentMedicines.join(', ')}. I cannot verify '
        'interactions between these and any new medicine — please confirm '
        'with a doctor or pharmacist before adding anything.',
      );
    }

    if (context.hasChronicConditions) {
      buffer.writeln();
      buffer.writeln(
        'Your saved profile lists: ${context.chronicConditions.join(', ')}. '
        'This may matter when choosing medicines — please confirm with a '
        'doctor or pharmacist.',
      );
    }

    return HealthAssistantResponse(
      text: buffer.toString().trim(),
      sosRecommended: false,
    );
  }

  /// True when an allergy from the saved profile conflicts with an OTC
  /// option. Case-insensitive substring match plus common category aliases
  /// (e.g. "NSAIDs" covers ibuprofen/aspirin/naproxen/diclofenac).
  bool _allergyMatchesOption(String allergy, String option) {
    final a = allergy.toLowerCase().trim();
    final o = option.toLowerCase();
    if (a.isEmpty) return false;
    if (o.contains(a)) return true;
    if (a == 'nsaid' || a == 'nsaids') {
      return const ['ibuprofen', 'aspirin', 'naproxen', 'diclofenac']
          .any(o.contains);
    }
    return false;
  }

  static const HealthAssistantResponse _general = HealthAssistantResponse(
    text:
        'I can offer general health and first-aid information, but I\'m not a '
        'doctor and I can\'t diagnose conditions. If you tell me your '
        'symptoms, I can suggest common non-prescription (OTC) medicine '
        'options that are generally used for them, along with precautions — '
        'but always confirm with a doctor or pharmacist before taking '
        'anything. For a minor issue like a small cut, clean it with water, '
        'apply gentle pressure, and cover it with a sterile dressing. If your '
        'symptoms are severe, getting worse, or you\'re unsure what to do, '
        'contact a healthcare professional or call emergency services. You '
        'can also ask me about headaches, fever, colds, coughs, sore throats, '
        'allergies, heartburn, nausea, constipation, diarrhea, minor pain, '
        'falls, bleeding, breathing difficulty, chest pain, or '
        'unconsciousness.',
    sosRecommended: false,
  );
}

/// Structured OTC guidance for a symptom category.
class _MedicationGuidance {
  const _MedicationGuidance({
    required this.selfCare,
    required this.otcOptions,
    required this.precautions,
    required this.whenToSeeDoctor,
    required this.emergencySigns,
  });

  final String selfCare;
  final List<String> otcOptions;
  final List<String> precautions;
  final String whenToSeeDoctor;
  final String emergencySigns;
}
