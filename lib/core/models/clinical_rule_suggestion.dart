class ClinicalRuleSuggestion {
  const ClinicalRuleSuggestion({
    required this.triggerType,
    required this.triggerValue,
    required this.suggestedAction,
    required this.evidenceRationale,
    this.contraindicatingConditions = const [],
    this.requiredMonitoring = const [],
    this.differentialDiagnoses = const [],
    this.recommendedInvestigations = const [],
    this.recommendedManagement = const [],
    this.sourceReference = '',
  });

  final String triggerType;
  final String triggerValue;
  final String suggestedAction;
  final String evidenceRationale;
  final List<String> contraindicatingConditions;
  final List<String> requiredMonitoring;
  final List<String> differentialDiagnoses;
  final List<String> recommendedInvestigations;
  final List<String> recommendedManagement;
  final String sourceReference;

  factory ClinicalRuleSuggestion.fromJson(Map<String, dynamic> json) {
    String requiredText(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Clinical rule $key must be a non-empty string.');
      }
      return value.trim();
    }

    final triggerType = requiredText('trigger_type').toLowerCase();
    if (triggerType != 'diagnosis' &&
        triggerType != 'symptom' &&
        triggerType != 'medication') {
      throw FormatException('Unsupported clinical rule trigger: $triggerType');
    }

    final sourceReferenceValue = json['source_reference'];
    if (sourceReferenceValue != null && sourceReferenceValue is! String) {
      throw const FormatException(
        'Clinical rule source_reference must be a string.',
      );
    }

    return ClinicalRuleSuggestion(
      triggerType: triggerType,
      triggerValue: requiredText('trigger_value'),
      suggestedAction: requiredText('suggested_action'),
      evidenceRationale: requiredText('evidence_rationale'),
      contraindicatingConditions: _stringList(
        json['contraindicating_conditions'],
        'contraindicating_conditions',
      ),
      requiredMonitoring: _stringList(
        json['required_monitoring'],
        'required_monitoring',
      ),
      differentialDiagnoses: _stringList(
        json['differential_diagnoses'],
        'differential_diagnoses',
      ),
      recommendedInvestigations: _stringList(
        json['recommended_investigations'],
        'recommended_investigations',
      ),
      recommendedManagement: _stringList(
        json['recommended_management'],
        'recommended_management',
      ),
      sourceReference: (sourceReferenceValue as String? ?? '').trim(),
    );
  }

  static List<String> _stringList(Object? value, String key) {
    if (value == null) return const [];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Clinical rule $key must be a string array.');
    }
    return value
        .map((item) => (item as String).trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
