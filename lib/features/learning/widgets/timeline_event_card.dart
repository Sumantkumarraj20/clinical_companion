import 'package:flutter/material.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/utils/datetime_utils.dart';

/// Distinct Material 3 card for one [TimelineEvent].
///
/// Each event kind gets its own icon and tint so a clinician scanning the feed
/// can tell an admission from a lab result without reading every line. Abnormal
/// labs are the deliberate exception: they wear the error container so they are
/// impossible to scroll past — the single most safety-relevant signal here.
class TimelineEventCard extends StatelessWidget {
  const TimelineEventCard({required this.event, this.onTap, super.key});

  final TimelineEvent event;
  final VoidCallback? onTap;

  IconData get _icon => switch (event.kind) {
    TimelineEventKind.admission => Icons.local_hospital_outlined,
    TimelineEventKind.encounter => Icons.medical_services_outlined,
    TimelineEventKind.labResult => Icons.science_outlined,
    TimelineEventKind.prescription => Icons.medication_outlined,
    TimelineEventKind.document => Icons.description_outlined,
  };

  String get _kindLabel => switch (event.kind) {
    TimelineEventKind.admission => 'Admission',
    TimelineEventKind.encounter => 'Encounter',
    TimelineEventKind.labResult => 'Investigation',
    TimelineEventKind.prescription => 'Prescription',
    TimelineEventKind.document => 'Scanned report',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final abnormal = event.isAbnormal;
    final muted = abnormal ? scheme.onErrorContainer : scheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: abnormal ? scheme.errorContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: abnormal ? scheme.error : scheme.outlineVariant,
          width: abnormal ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: abnormal
                    ? scheme.error
                    : scheme.primaryContainer,
                child: Icon(
                  _icon,
                  size: 18,
                  color: abnormal ? scheme.onError : scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _body(context, theme, abnormal, muted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ThemeData theme,
    bool abnormal,
    Color muted,
  ) {
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _kindLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          event.title ?? '(untitled)',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: abnormal ? scheme.onErrorContainer : scheme.onSurface,
          ),
        ),
        if (event.subtitle?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 2),
          Text(
            event.subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        if (event.detail?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(
            event.detail!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: (abnormal ? scheme.onErrorContainer : scheme.onSurface)
                  .withValues(alpha: 0.8),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.schedule, size: 12, color: scheme.outline),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                DateTimeUtils.relative(event.timestamp),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ),
            if (abnormal)
              Text(
                'ABNORMAL',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onErrorContainer,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
