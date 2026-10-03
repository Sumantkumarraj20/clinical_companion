import 'package:flutter/material.dart';

import '../../../core/cds/decision_support_engine.dart';
import '../../../core/database/local_database.dart';
import 'cohort_tagger.dart' show CohortTag;

/// The kind of record shown in a timeline feed card.
enum TimelineEntryKind { encounter, labResult, document, procedure }

/// One chronological item in the unified patient feed.
///
/// The feed merges three historically separate stores — encounters, lab results
/// and scanned documents — so a clinician reads one continuous story instead of
/// cross-referencing tabs.
@immutable
class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.kind,
    required this.timestamp,
    this.encounter,
    this.result,
    this.document,
    this.intervention,
    this.prescriptions = const [],
  });

  final String id;
  final TimelineEntryKind kind;
  final DateTime timestamp;

  final ClinicalEncounter? encounter;
  final InvestigationResult? result;
  final DocumentRegistry? document;
  final ClinicalIntervention? intervention;

  /// Drugs ordered during this encounter, used for the encounter card summary.
  final List<PrescriptionOrder> prescriptions;

  /// Date without the time-of-day, used for the feed's day separators.
  DateTime get day => DateTime(
    timestamp.toLocal().year,
    timestamp.toLocal().month,
    timestamp.toLocal().day,
  );
}

/// Everything the timeline screen renders, loaded in one pass.
class PatientTimelineBundle {
  const PatientTimelineBundle({
    required this.entries,
    required this.problems,
    required this.interventions,
    required this.alerts,
    required this.cohortTags,
  });

  final List<TimelineEntry> entries;
  final List<PatientProblem> problems;
  final List<ClinicalIntervention> interventions;
  final List<CdssAlert> alerts;

  /// Derived cohort tags shown in the header (see `CohortTagger`).
  final List<CohortTag> cohortTags;

  static const empty = PatientTimelineBundle(
    entries: [],
    problems: [],
    interventions: [],
    alerts: [],
    cohortTags: [],
  );
}

/// Builds the [PatientTimelineBundle] for one patient.
///
/// Lives outside the widget so the merge + sort can be unit-tested against
/// plain data, which is where the "newest first, never drop a record"
/// invariant actually matters.
class PatientTimelineBuilder {
  const PatientTimelineBuilder._();

  static PatientTimelineBundle build({
    required List<ClinicalEncounter> encounters,
    required List<InvestigationResult> results,
    required List<DocumentRegistry> documents,
    required List<ClinicalIntervention> interventions,
    required List<PrescriptionOrder> prescriptions,
    required List<PatientProblem> problems,
    required List<CohortTag> cohortTags,
    List<CdssAlert> alerts = const [],
  }) {
    // Index prescriptions by encounter so an encounter card can summarise the
    // drugs it produced without a second query.
    final byEncounter = <String, List<PrescriptionOrder>>{};
    for (final prescription in prescriptions) {
      final encounterId = prescription.encounterId;
      if (encounterId.isEmpty) continue;
      byEncounter.putIfAbsent(encounterId, () => []).add(prescription);
    }

    final entries = <TimelineEntry>[
      for (final encounter in encounters)
        TimelineEntry(
          id: 'enc-${encounter.id}',
          kind: TimelineEntryKind.encounter,
          timestamp: encounter.occurredAt,
          encounter: encounter,
          prescriptions: byEncounter[encounter.id] ?? const [],
        ),
      for (final result in results)
        TimelineEntry(
          id: 'res-${result.id}',
          kind: TimelineEntryKind.labResult,
          timestamp: result.resultDate,
          result: result,
        ),
      for (final document in documents)
        TimelineEntry(
          id: 'doc-${document.id}',
          kind: TimelineEntryKind.document,
          timestamp: document.documentedAt,
          document: document,
        ),
      for (final intervention in interventions)
        TimelineEntry(
          id: 'int-${intervention.id}',
          kind: TimelineEntryKind.procedure,
          timestamp: intervention.performedAt,
          intervention: intervention,
        ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return PatientTimelineBundle(
      entries: entries,
      problems: problems,
      interventions: interventions,
      alerts: alerts,
      cohortTags: cohortTags,
    );
  }

  /// The calendar day of each entry, positionally aligned with [entries].
  ///
  /// The feed uses this to decide where to draw a day separator, and a test
  /// asserts the "one header per day" rule.
  static List<DateTime> dayKeys(List<TimelineEntry> entries) {
    return [for (final entry in entries) entry.day];
  }
}

/// Patient-scoped alerts that must never be scrolled past.
///
/// Combines vitals-derived CDSS warnings (from the most recent encounter) with
/// allergy text captured in the chart. Allergy lives in a free-text column, so
/// only an explicit "allerg"/"intolerant" marker is trusted — guessing from
/// drug names would produce false alarms that train clinicians to ignore the
/// banner.
class PatientAlertEngine {
  const PatientAlertEngine._();

  static const _allergyMarkers = ['allerg', 'intolerant', 'known allergy'];

  /// Derives allergy banners from the encounter narrative columns.
  static List<CdssAlert> fromEncounters(List<ClinicalEncounter> encounters) {
    final alerts = <CdssAlert>[];
    final seen = <String>{};

    for (final encounter in encounters) {
      final history = [
        encounter.drugAndAllergyHistory,
        encounter.pastHistory,
      ].whereType<String>().join(' | ');
      final lower = history.toLowerCase();
      if (lower.trim().isEmpty) continue;
      if (!_allergyMarkers.any((marker) => lower.contains(marker))) continue;

      // Capture the sentence around the marker rather than dumping the whole
      // history, which is usually a paragraph.
      final snippet = _snippetAround(lower, _allergyMarkers) ?? history.trim();
      final label = snippet.length > 90
          ? '${snippet.substring(0, 90)}…'
          : snippet;
      if (!seen.add(label.toLowerCase())) continue;

      alerts.add(
        CdssAlert(
          title: 'Allergy on record',
          description: label,
          severityColor: const Color(0xFFB00020),
        ),
      );
    }
    return alerts;
  }

  static String? _snippetAround(String text, List<String> markers) {
    for (final marker in markers) {
      final index = text.indexOf(marker);
      if (index < 0) continue;
      final start = (index - 30).clamp(0, text.length);
      final end = (index + 70).clamp(0, text.length);
      return text.substring(start, end).trim();
    }
    return null;
  }
}
