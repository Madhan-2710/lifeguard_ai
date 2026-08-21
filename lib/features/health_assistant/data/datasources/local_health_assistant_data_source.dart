import '../../domain/entities/health_assistant_response.dart';
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
/// Safety rules enforced here:
/// - never diagnoses a condition
/// - never prescribes prescription-only medication
/// - never claims the user is medically safe
/// - OTC suggestions always include precautions and doctor/pharmacist advice
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
  Future<HealthAssistantResponse> getResponse(String userMessage) async {
    final text = userMessage.toLowerCase();

    // Critical emergencies are always handled first and always recommend SOS.
    if (_matchesAny(text, _unconsciousKeywords)) return _unconscious;
    if (_matchesAny(text, _chestPainKeywords)) return _chestPain;
    if (_matchesAny(text, _breathingKeywords)) return _breathing;
    if (_matchesAny(text, _bleedingKeywords)) return _bleeding;
    if (_matchesAny(text, _fallKeywords)) return _fall;

    // Common symptoms where OTC medicine guidance may be appropriate.
    if (_matchesAny(text, _headacheKeywords)) return _headache;
    if (_matchesAny(text, _feverKeywords)) return _fever;
    if (_matchesAny(text, _coldFluKeywords)) return _coldFlu;
    if (_matchesAny(text, _coughKeywords)) return _cough;
    if (_matchesAny(text, _soreThroatKeywords)) return _soreThroat;
    if (_matchesAny(text, _allergyKeywords)) return _allergy;
    if (_matchesAny(text, _heartburnKeywords)) return _heartburn;
    if (_matchesAny(text, _nauseaKeywords)) return _nausea;
    if (_matchesAny(text, _constipationKeywords)) return _constipation;
    if (_matchesAny(text, _diarrheaKeywords)) return _diarrhea;
    if (_matchesAny(text, _painKeywords)) return _pain;

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

  static const HealthAssistantResponse _headache = HealthAssistantResponse(
    text:
        '1. What you can do now: Rest in a quiet, dim room, drink water, and '
        'apply a cool or warm compress to your head or neck. Avoid screens, '
        'caffeine, and alcohol if they seem to trigger it.\n'
        '2. Possible OTC medicine options: For occasional tension headaches, '
        'common OTC options include acetaminophen (paracetamol) or ibuprofen, '
        'taken exactly as directed on the label. These are general suggestions '
        '— check with a pharmacist that they are right for you.\n'
        '3. Important precautions: Do not exceed the label dose, and avoid '
        'using pain relievers more than a few days per week (this can cause '
        'rebound headaches). Avoid ibuprofen or aspirin if you have stomach '
        'ulcers, kidney problems, or are pregnant unless a doctor says it\'s '
        'OK. Never give aspirin to anyone under 16.\n'
        '4. When to see a doctor: If headaches are frequent, severe, or '
        'getting worse, or if you need pain relievers more than twice a '
        'week.\n'
        '5. Emergency warning signs: A sudden, severe "worst-ever" headache, '
        'or a headache with fever and stiff neck, confusion, weakness, '
        'numbness, vision changes, or after a head injury — call emergency '
        'services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _fever = HealthAssistantResponse(
    text:
        '1. What you can do now: Rest, drink plenty of fluids, and dress '
        'lightly. A lukewarm (not cold) sponge bath can help you feel more '
        'comfortable.\n'
        '2. Possible OTC medicine options: Acetaminophen (paracetamol) or '
        'ibuprofen are common OTC options to reduce fever, taken exactly as '
        'directed on the label. These are general suggestions — check with a '
        'pharmacist that they are right for you.\n'
        '3. Important precautions: Do not exceed the label dose and do not '
        'combine multiple products containing the same ingredient. Avoid '
        'ibuprofen or aspirin if you have stomach ulcers, kidney problems, or '
        'are pregnant unless a doctor says it\'s OK. Never give aspirin to '
        'anyone under 16.\n'
        '4. When to see a doctor: If a fever lasts more than 3 days, is very '
        'high, or you have a weakened immune system, a chronic condition, or '
        'are pregnant.\n'
        '5. Emergency warning signs: Fever with a stiff neck, severe '
        'headache, confusion, difficulty breathing, a rash that doesn\'t '
        'fade, or seizures — call emergency services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _coldFlu = HealthAssistantResponse(
    text:
        '1. What you can do now: Rest, drink warm fluids, and use a '
        'humidifier or steam to ease congestion. Saline nasal spray or rinses '
        'can help a stuffy nose.\n'
        '2. Possible OTC medicine options: Common OTC options include '
        'decongestants (e.g., pseudoephedrine or phenylephrine) for a blocked '
        'nose, cough suppressants or expectorants for a cough, and '
        'acetaminophen or ibuprofen for aches or fever. These are general '
        'suggestions — check with a pharmacist that they are right for you.\n'
        '3. Important precautions: Avoid taking multiple cold products at '
        'once — many contain the same ingredients (e.g., acetaminophen) and '
        'doubling up can be dangerous. Decongestants can raise blood '
        'pressure, so check with a pharmacist if you have heart problems or '
        'high blood pressure. Do not give cough and cold medicines to '
        'children under 6 without professional advice.\n'
        '4. When to see a doctor: If symptoms last more than 10 days, get '
        'worse, or you have a chronic condition (asthma, diabetes, heart '
        'disease) or are pregnant.\n'
        '5. Emergency warning signs: Difficulty breathing, chest pain, '
        'confusion, or a high fever that won\'t come down — call emergency '
        'services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _cough = HealthAssistantResponse(
    text:
        '1. What you can do now: Drink warm fluids like honey and lemon in '
        'warm water (not for babies under 1), rest, and use steam from a hot '
        'shower to soothe your airways.\n'
        '2. Possible OTC medicine options: Common OTC options include cough '
        'suppressants (e.g., dextromethorphan) for a dry, tickly cough, or '
        'expectorants (e.g., guaifenesin) for a chesty cough. These are '
        'general suggestions — check with a pharmacist that they are right '
        'for you.\n'
        '3. Important precautions: Do not give cough medicines to children '
        'under 6 without professional advice. Avoid combining multiple cough '
        'products. If you have asthma, COPD, or other lung conditions, check '
        'with a pharmacist or doctor first.\n'
        '4. When to see a doctor: If a cough lasts more than 3 weeks, brings '
        'up blood, or is accompanied by fever, weight loss, or shortness of '
        'breath.\n'
        '5. Emergency warning signs: Coughing up blood, difficulty breathing, '
        'chest pain, or lips turning blue — call emergency services right '
        'away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _soreThroat = HealthAssistantResponse(
    text:
        '1. What you can do now: Drink warm fluids, gargle with warm salt '
        'water, and suck on ice chips or lozenges to soothe the throat. Rest '
        'your voice.\n'
        '2. Possible OTC medicine options: Common OTC options include throat '
        'lozenges or sprays with local anesthetics (e.g., benzocaine), and '
        'acetaminophen or ibuprofen for pain. These are general suggestions — '
        'check with a pharmacist that they are right for you.\n'
        '3. Important precautions: Do not exceed the label dose of lozenges '
        'or sprays. Avoid ibuprofen or aspirin if you have stomach ulcers, '
        'kidney problems, or are pregnant unless a doctor says it\'s OK. '
        'Never give aspirin to anyone under 16.\n'
        '4. When to see a doctor: If a sore throat lasts more than a week, is '
        'very painful, or comes with a high fever, swollen glands, or white '
        'patches — a bacterial infection may need evaluation.\n'
        '5. Emergency warning signs: Difficulty swallowing or breathing, '
        'drooling, muffled voice, or a swollen throat — call emergency '
        'services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _allergy = HealthAssistantResponse(
    text:
        '1. What you can do now: Avoid the trigger where possible, rinse your '
        'eyes with clean water, and use a saline nasal rinse to flush '
        'allergens.\n'
        '2. Possible OTC medicine options: Common OTC options include '
        'non-drowsy antihistamines (e.g., cetirizine, loratadine, '
        'fexofenadine) and antihistamine eye drops for itchy eyes. These are '
        'general suggestions — check with a pharmacist that they are right '
        'for you.\n'
        '3. Important precautions: Some antihistamines (e.g., '
        'diphenhydramine) cause drowsiness — avoid driving or operating '
        'machinery. Check with a pharmacist if you have liver or kidney '
        'problems, are pregnant, or take other medicines.\n'
        '4. When to see a doctor: If symptoms are severe, don\'t improve with '
        'OTC options, or you have asthma alongside allergies.\n'
        '5. Emergency warning signs: Swelling of the face, lips, or tongue, '
        'difficulty breathing, wheezing, or a widespread rash after exposure '
        '— call emergency services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _heartburn = HealthAssistantResponse(
    text:
        '1. What you can do now: Eat smaller meals, avoid lying down for 2-3 '
        'hours after eating, and avoid spicy, fatty, or acidic foods, '
        'caffeine, and alcohol.\n'
        '2. Possible OTC medicine options: Common OTC options include '
        'antacids (e.g., calcium carbonate, magnesium hydroxide) for quick '
        'relief, and H2 blockers (e.g., famotidine) or proton pump inhibitors '
        '(e.g., omeprazole) for longer-lasting relief. These are general '
        'suggestions — check with a pharmacist that they are right for you.\n'
        '3. Important precautions: Do not take antacids at the same time as '
        'other medicines (they can affect absorption). Long-term use of PPIs '
        'should be reviewed by a doctor. Check with a pharmacist if you have '
        'kidney problems or take other medicines.\n'
        '4. When to see a doctor: If heartburn happens more than twice a '
        'week, lasts more than 2 weeks despite treatment, or you have '
        'difficulty swallowing or unintentional weight loss.\n'
        '5. Emergency warning signs: Chest pain that spreads to your arm, '
        'neck, or jaw, or comes with sweating, shortness of breath, or '
        'nausea — call emergency services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _nausea = HealthAssistantResponse(
    text:
        '1. What you can do now: Sip clear fluids slowly (water, ginger tea, '
        'or oral rehydration solution), eat small bland meals like crackers '
        'or toast, and rest. Avoid strong smells, greasy, or spicy food.\n'
        '2. Possible OTC medicine options: Common OTC options include '
        'dimenhydrinate (for motion sickness) or antacids if the nausea is '
        'linked to indigestion. Ginger products may help mild nausea. These '
        'are general suggestions — check with a pharmacist that they are '
        'right for you.\n'
        '3. Important precautions: Do not take anti-nausea medicines if you '
        'have severe abdominal pain without checking with a pharmacist. Check '
        'with a pharmacist if you are pregnant or take other medicines.\n'
        '4. When to see a doctor: If nausea lasts more than 2 days, you '
        'can\'t keep fluids down, or you have signs of dehydration.\n'
        '5. Emergency warning signs: Nausea with severe abdominal pain, '
        'chest pain, confusion, stiff neck, or vomiting blood — call '
        'emergency services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _constipation = HealthAssistantResponse(
    text:
        '1. What you can do now: Drink more water, increase fiber gradually '
        '(fruits, vegetables, whole grains), and stay active. Try to respond '
        'to the urge to go.\n'
        '2. Possible OTC medicine options: Common OTC options include '
        'bulk-forming laxatives (e.g., psyllium), stool softeners (e.g., '
        'docusate), or osmotic laxatives (e.g., polyethylene glycol). These '
        'are general suggestions — check with a pharmacist that they are '
        'right for you.\n'
        '3. Important precautions: Drink plenty of water with fiber or '
        'bulk-forming laxatives. Do not use stimulant laxatives regularly — '
        'they can cause dependence. Check with a pharmacist if you are '
        'pregnant or take other medicines.\n'
        '4. When to see a doctor: If constipation lasts more than 3 weeks, is '
        'severe, or comes with abdominal pain, blood in the stool, or '
        'unexplained weight loss.\n'
        '5. Emergency warning signs: Severe abdominal pain, vomiting, '
        'inability to pass gas, or blood in the stool — call emergency '
        'services right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _diarrhea = HealthAssistantResponse(
    text:
        '1. What you can do now: The most important thing is to replace '
        'fluids — sip water, oral rehydration solution (ORS), or clear '
        'broths frequently. Eat bland foods like rice, bananas, and toast.\n'
        '2. Possible OTC medicine options: Oral rehydration salts (ORS) are '
        'the safest first choice. Loperamide can slow diarrhea but should '
        'only be used for mild, non-fever diarrhea in adults. These are '
        'general suggestions — check with a pharmacist that they are right '
        'for you.\n'
        '3. Important precautions: Do not use loperamide if you have a '
        'fever, blood in the stool, or think the cause may be bacterial — '
        'this can make it worse. Do not give loperamide to children without '
        'professional advice.\n'
        '4. When to see a doctor: If diarrhea lasts more than 2 days (or '
        'more than 24 hours in a child), or you have a high fever, blood in '
        'the stool, or signs of dehydration.\n'
        '5. Emergency warning signs: Severe dehydration (dizziness, dark '
        'urine, dry mouth, little or no urination), blood in the stool, or '
        'severe abdominal pain — seek medical care right away.',
    sosRecommended: false,
  );

  static const HealthAssistantResponse _pain = HealthAssistantResponse(
    text:
        '1. What you can do now: Rest the area, apply ice for the first 24-48 '
        'hours (15-20 minutes at a time, wrapped in a cloth), then heat. '
        'Elevate the area if possible.\n'
        '2. Possible OTC medicine options: Common OTC options include '
        'acetaminophen (paracetamol) or ibuprofen for pain and inflammation, '
        'and topical creams or gels (e.g., menthol, diclofenac gel). These '
        'are general suggestions — check with a pharmacist that they are '
        'right for you.\n'
        '3. Important precautions: Do not exceed the label dose. Avoid '
        'ibuprofen or aspirin if you have stomach ulcers, kidney problems, or '
        'are pregnant unless a doctor says it\'s OK. Never give aspirin to '
        'anyone under 16.\n'
        '4. When to see a doctor: If pain is severe, doesn\'t improve after '
        'a few days, or you can\'t put weight on the area.\n'
        '5. Emergency warning signs: Pain with deformity, numbness, '
        'tingling, or inability to move the limb, or pain after a serious '
        'injury — seek medical care right away.',
    sosRecommended: false,
  );

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
