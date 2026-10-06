class PatientClinicalContext {
  const PatientClinicalContext({
    required this.allergyHistory,
    required this.activeProblems,
    required this.recentVitals,
    required this.recentSymptoms,
  });

  final String allergyHistory;
  final List<String> activeProblems;
  final List<String> recentVitals;
  final List<String> recentSymptoms;

  PatientClinicalContext copyWith({
    String? allergyHistory,
    List<String>? activeProblems,
    List<String>? recentVitals,
    List<String>? recentSymptoms,
  }) => PatientClinicalContext(
    allergyHistory: allergyHistory ?? this.allergyHistory,
    activeProblems: activeProblems ?? this.activeProblems,
    recentVitals: recentVitals ?? this.recentVitals,
    recentSymptoms: recentSymptoms ?? this.recentSymptoms,
  );
}
