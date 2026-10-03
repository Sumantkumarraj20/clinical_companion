import 'package:flutter/material.dart';

import '../../../core/database/local_database.dart';
import '../../../core/utils/datetime_utils.dart';

/// A derived, human-readable label for grouping patients in research cohorts
/// (`#AcuteAppendicitis`, `#PostOpDay3`, `#Neurosurgery`).
///
/// Cohort tags are *derived* rather than stored: they are recomputed from the
/// POMR on every read, so a diagnosis that gets resolved — or a problem added
/// later — corrects the tag automatically and can never drift out of sync with
/// the clinical record.
@immutable
class CohortTag {
  const CohortTag(this.label, {required this.kind, required this.source});

  /// Display text *without* the leading '#'; the UI adds it.
  final String label;

  /// Drives chip colour so a surgical cohort reads differently to a diagnosis.
  final CohortTagKind kind;

  /// What produced the tag — shown as a tooltip ("from problem: Pneumonia").
  final String source;

  String get display => '#$label';

  /// Chip colour: a diagnosis reads blue, a surgical cohort purple and a
  /// demographic band teal, so a mixed tag row stays scannable at a glance.
  Color get chipColor => switch (kind) {
    CohortTagKind.diagnosis => const Color(0xFF1565C0),
    CohortTagKind.surgical => const Color(0xFF6A1B9A),
    CohortTagKind.demographic => const Color(0xFF00695C),
  };

  IconData get chipIcon => switch (kind) {
    CohortTagKind.diagnosis => Icons.local_hospital_outlined,
    CohortTagKind.surgical => Icons.medical_services_outlined,
    CohortTagKind.demographic => Icons.groups_outlined,
  };

  @override
  bool operator ==(Object other) =>
      other is CohortTag && other.label == label && other.kind == kind;

  @override
  int get hashCode => Object.hash(label, kind);

  @override
  String toString() => 'CohortTag($display, ${kind.name})';
}

enum CohortTagKind {
  /// Derived from an active problem / diagnosis.
  diagnosis,

  /// Derived from a performed procedure or its post-op day.
  surgical,

  /// Derived from an age band.
  demographic,
}

/// Derives [CohortTag]s from a patient's POMR.
///
/// Kept as pure functions so the derivation is unit-testable and identical in
/// the patient header, the registry filter row and any future export.
class CohortTagger {
  const CohortTagger._();

  static const _stopWords = {
    'acute',
    'chronic',
    'with',
    'and',
    'of',
    'the',
    'a',
    'an',
    'localized',
    'generalised',
    'generalized',
  };

  /// Specialties recognised by name so surgical cases collapse into a handful
  /// of usable research cohorts instead of one tag per procedure.
  static const _specialtyMap = <String, String>{
    'neuro': 'Neurosurgery',
    'cranio': 'Neurosurgery',
    'brain': 'Neurosurgery',
    'spine': 'Neurosurgery',
    'cardio': 'Cardiology',
    'angio': 'Cardiology',
    'bypass': 'Cardiology',
    'ortho': 'Orthopaedics',
    'arthro': 'Orthopaedics',
    'fracture': 'Orthopaedics',
    'append': 'General Surgery',
    'chole': 'General Surgery',
    'hernia': 'General Surgery',
    'lap': 'General Surgery',
    'lapar': 'General Surgery',
    'obstet': 'Obstetrics',
    'gynae': 'Obstetrics',
    'gyna': 'Obstetrics',
    'paed': 'Paediatrics',
    'pedi': 'Paediatrics',
    'onco': 'Oncology',
    'urol': 'Urology',
  };

  /// Builds the full tag set for a patient.
  ///
  /// [now] is injectable so "post-op day N" is deterministic in tests.
  static List<CohortTag> tagsFor({
    required List<PatientProblem> problems,
    required List<ClinicalIntervention> interventions,
    Patient? patient,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final tags = <String, CohortTag>{};

    void add(CohortTag tag) => tags.putIfAbsent(tag.label, () => tag);

    // --- Active problems -> diagnosis cohorts ---------------------------
    for (final problem in problems) {
      if (problem.currentStatus.toLowerCase() == 'resolved') continue;

      // Recover the emphasis word ("Acute Appendicitis" -> "AcuteAppendicitis")
      // so the tag matches how a clinician actually thinks about the case.
      add(
        CohortTag(
          _emphasise(problem.problemName),
          kind: CohortTagKind.diagnosis,
          source: 'Problem: ${problem.problemName}',
        ),
      );

      final specialty = _specialtyFor(problem.problemName);
      if (specialty != null) {
        add(
          CohortTag(
            specialty,
            kind: CohortTagKind.surgical,
            source: 'From problem: ${problem.problemName}',
          ),
        );
      }
    }

    // --- Procedures -> specialty + post-op day -------------------------
    for (final intervention in interventions) {
      final name = intervention.procedureName;
      final specialty = _specialtyFor(name);
      if (specialty != null) {
        add(
          CohortTag(
            specialty,
            kind: CohortTagKind.surgical,
            source: 'Procedure: $name',
          ),
        );
      }

      final postOpDay = _postOpDay(intervention.performedAt, clock);
      if (postOpDay != null && postOpDay <= 14) {
        add(
          CohortTag(
            'PostOpDay$postOpDay',
            kind: CohortTagKind.surgical,
            source: 'Post-op day $postOpDay after $name',
          ),
        );
      }
    }

    // --- Demographic band ----------------------------------------------
    if (patient != null) {
      final age = DateTimeUtils.ageOn(patient.dateOfBirth, clock);
      if (age != null) {
        if (age < 16) {
          add(
            const CohortTag(
              'Paediatric',
              kind: CohortTagKind.demographic,
              source: 'Age under 16 years',
            ),
          );
        } else if (age >= 65) {
          add(
            const CohortTag(
              'Geriatric',
              kind: CohortTagKind.demographic,
              source: 'Age 65 years or older',
            ),
          );
        }
      }
      final gender = patient.gender?.trim().toLowerCase();
      if (gender == 'f' || gender == 'female') {
        add(
          const CohortTag(
            'Female',
            kind: CohortTagKind.demographic,
            source: 'Recorded gender',
          ),
        );
      }
    }

    final ordered = tags.values.toList()
      ..sort((a, b) {
        final byKind = a.kind.index.compareTo(b.kind.index);
        return byKind != 0 ? byKind : a.label.compareTo(b.label);
      });
    return ordered;
  }

  /// `"Acute Appendicitis with Localised Peritonitis"` -> `AcuteAppendicitis`.
  ///
  /// Keeps a leading qualifier ("Acute", "Chronic") plus the first substantive
  /// noun, because that is the phrase a clinician would actually filter by.
  static String _emphasise(String problemName) {
    final words = problemName
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return slugify(problemName);

    final qualifier = words.first;
    final isQualifier = const [
      'acute',
      'chronic',
      'recurrent',
      'severe',
      'mild',
    ].contains(qualifier.toLowerCase());

    final substantive = words
        .skip(isQualifier ? 1 : 0)
        .firstWhere(
          (word) => !_stopWords.contains(word.toLowerCase()),
          orElse: () => words.first,
        );

    return isQualifier ? '$qualifier$substantive' : substantive;
  }

  /// Maps free text onto a stable specialty cohort, or null when unclear.
  static String? _specialtyFor(String text) {
    final lower = text.toLowerCase();
    for (final entry in _specialtyMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static int? _postOpDay(DateTime performedAt, DateTime now) {
    final performed = performedAt.toLocal();
    final today = now.toLocal();
    final difference = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(performed.year, performed.month, performed.day));
    final days = difference.inDays + 1; // day of surgery counts as day 1
    return days <= 0 ? null : days;
  }

  /// Strips punctuation so a derived tag is always tag-safe.
  static String slugify(String value) {
    return value
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .join();
  }
}

/// Compact tag row rendered under the patient name in the timeline header.
class CohortTagStrip extends StatelessWidget {
  const CohortTagStrip({
    required this.tags,
    this.onTap,
    this.maxVisible = 6,
    super.key,
  });

  final List<CohortTag> tags;

  /// When provided each tag becomes tappable (used to filter the feed below).
  final ValueChanged<CohortTag>? onTap;

  /// Chips beyond this collapse into a "+N" chip so a heavily comorbid patient
  /// cannot push the clinical content off-screen.
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    final visible = tags.take(maxVisible).toList();
    final hidden = tags.length - visible.length;

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length + (hidden > 0 ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index >= visible.length) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+$hidden',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          return CohortTagChip(
            tag: visible[index],
            onTap: onTap == null ? null : () => onTap!(visible[index]),
          );
        },
      ),
    );
  }
}

/// A single cohort chip, themed for a dark app bar.
class CohortTagChip extends StatelessWidget {
  const CohortTagChip({required this.tag, this.onTap, super.key});

  final CohortTag tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tag.source,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tag.chipIcon, size: 11, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                tag.display,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Registry-wide cohort filter row.
///
/// A clinician studying a cohort (say every `#Neurosurgery` case) taps one chip
/// and the whole patient list narrows — the same tags the header shows, reused
/// as the entry point into population-level research.
class CohortFilterBar extends StatelessWidget {
  const CohortFilterBar({
    required this.available,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  /// Every cohort tag present across the registry, with its patient count.
  final Map<CohortTag, int> available;
  final Set<String> selected;
  final void Function(String tag) onToggle;

  @override
  Widget build(BuildContext context) {
    if (available.isEmpty) return const SizedBox.shrink();

    final entries = available.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isSelected = selected.contains(entry.key.label);
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              entry.key.chipIcon,
              size: 14,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : entry.key.chipColor,
            ),
            label: Text('${entry.key.display} (${entry.value})'),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onToggle(entry.key.label),
          );
        },
      ),
    );
  }
}
