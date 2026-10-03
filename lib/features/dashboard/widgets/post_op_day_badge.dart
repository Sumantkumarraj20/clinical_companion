import 'package:flutter/material.dart';

/// Post-operative day badge for a patient card.
///
/// Shows "POD #N" — the number of days since the most recent *surgical*
/// intervention. It is deliberately a factual count with no advice attached:
/// the app tracks what was recorded, it does not tell the clinician what the
/// patient should be having on that day.
///
/// Renders nothing when the patient has no recorded surgery, and also nothing
/// for a *future-dated* procedure — a negative post-op day is a data-entry
/// error, not a clinical state, and showing "POD #-1" would propagate it.
class PostOpDayBadge extends StatelessWidget {
  const PostOpDayBadge({
    required this.postOpDay,
    this.procedureName,
    super.key,
  });

  /// Days elapsed since surgery. May be null when no surgery is on record.
  final int? postOpDay;

  /// Optional procedure label, surfaced in the tooltip for context.
  final String? procedureName;

  /// Colour-codes the day range so a long stay is visible at a glance.
  /// These are *presentation* bands only — not risk scores or thresholds.
  static Color _backgroundFor(BuildContext context, int day) {
    final scheme = Theme.of(context).colorScheme;
    if (day <= 1) return scheme.primaryContainer;
    if (day <= 7) return scheme.tertiaryContainer;
    if (day <= 14) return scheme.secondaryContainer;
    return scheme.surfaceContainerHighest;
  }

  @override
  Widget build(BuildContext context) {
    final day = postOpDay;
    if (day == null || day < 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final label = 'POD #$day';

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundFor(context, day),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        // A chip is sized to its text; the FittedBox keeps long values from
        // overflowing inside a narrow ward-round card.
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );

    final tooltip = procedureName?.trim();
    if (tooltip == null || tooltip.isEmpty) return chip;

    return Tooltip(message: 'Post-operative day $day · $tooltip', child: chip);
  }
}
