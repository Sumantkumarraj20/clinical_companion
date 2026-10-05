/// One evidence-based chart-audit recommendation from ClinCom.
class ClinicalInsight {
  const ClinicalInsight({
    required this.type,
    required this.title,
    required this.reasoning,
    this.actionableItems = const [],
  });

  static const types = {
    'missing_investigation',
    'management_suggestion',
    'differential_diagnosis',
    'warning',
  };

  final String type;
  final String title;
  final String reasoning;
  final List<String> actionableItems;

  factory ClinicalInsight.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'];
    if (rawType is! String) {
      throw const FormatException('Clinical insight type must be a string.');
    }
    final type = rawType;
    if (!types.contains(type)) {
      throw FormatException('Unknown clinical insight type: $type');
    }
    final rawTitle = json['title'];
    final rawReasoning = json['reasoning'];
    if (rawTitle is! String || rawReasoning is! String) {
      throw const FormatException(
        'Clinical insight title and reasoning must be strings.',
      );
    }
    final title = rawTitle.trim();
    final reasoning = rawReasoning.trim();
    if (title.isEmpty || reasoning.isEmpty) {
      throw const FormatException(
        'Clinical insight title and reasoning are required.',
      );
    }
    final rawItems = json['actionable_items'];
    if (rawItems is! List || rawItems.any((item) => item is! String)) {
      throw const FormatException(
        'Clinical insight actionable_items must be a string array.',
      );
    }
    return ClinicalInsight(
      type: type,
      title: title,
      reasoning: reasoning,
      actionableItems: rawItems
          .map((item) => (item as String).trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
  }
}

/// A frequent, clinician-accepted category of chart-audit suggestion.
class ClinicalBlindSpot {
  const ClinicalBlindSpot({
    required this.title,
    required this.suggestionType,
    required this.acceptedCount,
  });

  final String title;
  final String suggestionType;
  final int acceptedCount;
}
