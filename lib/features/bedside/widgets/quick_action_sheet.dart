import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// A single destination on the clinician's steering wheel.
@immutable
class QuickAction {
  const QuickAction({
    required this.label,
    required this.caption,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
}

/// Opens the [QuickActionSheet].
///
/// Split out so both the global FAB and any screen-local "add" affordance can
/// raise the same sheet without duplicating the action list.
Future<void> showQuickActionSheet(BuildContext context) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    // The sheet is the primary entry point for capture, so it takes over most
    // of the screen and is dismissed with a tap outside or a swipe.
    constraints: const BoxConstraints(maxHeight: 760),
    builder: (sheetContext) => const QuickActionSheet(),
  );
}

/// The clinician's steering wheel.
///
/// Capture is deliberately two taps from *anywhere*: open the sheet, tap an
/// action. Every tile is a large, thumb-sized Material 3 card rather than a
/// list row, because it is used one-handed, often while holding a paper file.
class QuickActionSheet extends StatelessWidget {
  const QuickActionSheet({super.key});

  /// Builds the grid contents for the actions available right now.
  static List<QuickAction> actionsFor(BuildContext context) {
    void go(String route, {Object? extra}) {
      context.pop();
      context.push(route, extra: extra);
    }

    return [
      QuickAction(
        label: 'Smart Scan',
        caption: 'Photograph a paper report',
        icon: Icons.document_scanner_outlined,
        tint: const Color(0xFF00695C),
        onTap: () => go('/smart-capture'),
      ),
      QuickAction(
        label: 'New OPD Consult',
        caption: 'Select or register patient',
        icon: Icons.assignment_ind_outlined,
        tint: const Color(0xFF1565C0),
        onTap: () => go('/patients', extra: const {'opdFlow': true}),
      ),
      QuickAction(
        label: 'Ward Round Note',
        caption: 'Quick IPD bedside entry',
        icon: Icons.local_hospital_outlined,
        tint: const Color(0xFF6A1B9A),
        onTap: () => go('/ward-dashboard'),
      ),
      QuickAction(
        label: 'Order Meds / Labs',
        caption: 'Catalog dosing & investigations',
        icon: Icons.medication_outlined,
        tint: const Color(0xFFB26A00),
        onTap: () => go('/labs'),
      ),
    ];
  }

  /// Tools that fell out of the four-destination bar when it was simplified.
  ///
  /// They stay two taps away through this sheet rather than taking a slot in the
  /// navigation bar, so the thumb zone stays reserved for the destinations a
  /// clinician actually moves between.
  static List<QuickAction> secondaryActionsFor(BuildContext context) {
    void go(String route) {
      context.pop();
      context.push(route);
    }

    return [
      QuickAction(
        label: 'Vitals',
        caption: 'Bedside observations',
        icon: Icons.monitor_heart_outlined,
        tint: const Color(0xFFAD1457),
        onTap: () => go('/vitals'),
      ),
      QuickAction(
        label: 'Ward Board',
        caption: 'Beds and census',
        icon: Icons.local_hotel_outlined,
        tint: const Color(0xFF00695C),
        onTap: () => go('/ward-dashboard'),
      ),
      QuickAction(
        label: 'Knowledge',
        caption: 'Personal wiki & protocols',
        icon: Icons.menu_book_outlined,
        tint: const Color(0xFF4527A0),
        onTap: () => go('/wiki'),
      ),
      QuickAction(
        label: 'Data & Sync',
        caption: 'Backup and export',
        icon: Icons.cloud_sync_outlined,
        tint: const Color(0xFF37474F),
        onTap: () => go('/data-management'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = actionsFor(context);
    final secondary = secondaryActionsFor(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Capture or start something without losing your place.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ActionGrid(actions: actions, aspectRatio: 1.08),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'More tools',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              // Wider tiles: these are shortcuts, not primary actions.
              // Sprint 14.5 — the ratio was 2.1, which made these cells ~75dp
              // tall. That forced the card into its compact mode and dropped
              // the captions, leaving the section looking like a row of bare
              // icons. 1.0 restores label AND caption at 320dp.
              child: _ActionGrid(actions: secondary, aspectRatio: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-column grid of [QuickAction] cards.
class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions, required this.aspectRatio});

  final List<QuickAction> actions;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Two columns keeps every tile above the 44dp touch minimum even on
      // small phones, where a 3-up grid would not.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _ActionCard(action: actions[index]),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The two grids use very different cell heights (primary ~1.08, secondary
    // wider/shorter), and a ward phone in landscape makes them shorter still.
    // A single fixed layout overflows one of them, so the card measures itself
    // and drops the caption when there is genuinely no room for it.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Icon (42) + gap (10) + 2-line label (~34) + 2 + 1-line caption (~14)
        // plus 28 of padding is ~130dp. Below that the card drops the caption
        // rather than clipping it mid-word.
        final compact = constraints.maxHeight < 120;

        return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: action.tint.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: action.tint.withValues(alpha: 0.35)),
          ),
          child: InkWell(
            onTap: action.onTap,
            child: Padding(
              padding: EdgeInsets.all(compact ? 10 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 7 : 9),
                    decoration: BoxDecoration(
                      color: action.tint.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.tint,
                      size: compact ? 20 : 24,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 10),
                  // Expanded (tight fit) guarantees the text block absorbs
                  // exactly the leftover height and scrolls inside it, so the
                  // outer Column can never overflow the fixed-height cell.
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            action.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!compact) ...[
                            const SizedBox(height: 2),
                            Text(
                              action.caption,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
