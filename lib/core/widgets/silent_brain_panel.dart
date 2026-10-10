import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cds/silent_brain.dart';
import '../database/local_database.dart';
import '../providers/app_providers.dart';

/// Quiet, collapsible safety-net panel.
///
/// It observes the text being typed through [refresh] and re-evaluates only
/// after the clinician pauses ([debounce]). The built-in checks run
/// immediately on that pause; the learned-protocol lookup runs asynchronously
/// against the local database and is dropped if newer text has arrived.
/// Nothing here blocks typing. Shows nothing when there is nothing to prompt,
/// and always frames items as prompts for the clinician to verify.
class SilentBrainPanel extends ConsumerStatefulWidget {
  const SilentBrainPanel({
    super.key,
    required this.inputBuilder,
    this.refresh,
    this.debounce = const Duration(milliseconds: 450),
  });

  /// Reads the current form state. Called only after the debounce.
  final BrainInput Function() inputBuilder;

  /// Notifies when the form text changes (e.g. `Listenable.merge(controllers)`).
  final Listenable? refresh;
  final Duration debounce;

  @override
  ConsumerState<SilentBrainPanel> createState() => _SilentBrainPanelState();
}

class _SilentBrainPanelState extends ConsumerState<SilentBrainPanel> {
  Timer? _timer;
  int _generation = 0;
  String _lastKeywordKey = '';
  List<CachedClinicalRule> _learned = const [];
  List<BrainInsight> _items = const [];

  @override
  void initState() {
    super.initState();
    widget.refresh?.addListener(_schedule);
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void didUpdateWidget(covariant SilentBrainPanel old) {
    super.didUpdateWidget(old);
    if (old.refresh != widget.refresh) {
      old.refresh?.removeListener(_schedule);
      widget.refresh?.addListener(_schedule);
    }
    // The parent supplied fresh context (e.g. history finished loading).
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.refresh?.removeListener(_schedule);
    super.dispose();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(widget.debounce, _run);
  }

  Future<void> _run() async {
    if (!mounted) return;
    final generation = ++_generation;
    final input = widget.inputBuilder();

    // Built-in prompts appear at once, with whatever learned rules we have.
    _publish(input);

    final keywords = LearnedRuleMatcher.keywords(input.allText);
    final key = keywords.join('|');
    if (key == _lastKeywordKey) return;
    _lastKeywordKey = key;
    if (keywords.isEmpty) {
      if (_learned.isNotEmpty) {
        _learned = const [];
        _publish(input);
      }
      return;
    }
    try {
      final found = await ref
          .read(clinicalRuleDaoProvider)
          .searchByKeywords(keywords);
      if (!mounted || generation != _generation) return;
      _learned = found;
      _publish(input);
    } catch (e, st) {
      // Fall back silently to the built-in prompts.
      debugPrint('Protocol lookup failed: $e\n$st');
      _lastKeywordKey = '';
    }
  }

  void _publish(BrainInput input) {
    if (!mounted) return;
    setState(() => _items = SilentBrain.evaluate(input, learned: _learned));
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final urgent = _items.where((e) => e.urgent).length;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      child: ExpansionTile(
        initiallyExpanded: urgent > 0,
        shape: const Border(),
        leading: Icon(
          urgent > 0 ? Icons.priority_high : Icons.lightbulb_outline,
          color: urgent > 0 ? scheme.error : scheme.primary,
        ),
        title: Text(
          urgent > 0
              ? '$urgent item${urgent == 1 ? '' : 's'} need attention'
              : 'Worth a second look (${_items.length})',
        ),
        subtitle: const Text(
          'Prompts for your review. Your judgement decides.',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in _items.take(16))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _icon(e.kind),
                    size: 18,
                    color: e.urgent ? scheme.error : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(e.rationale, style: theme.textTheme.bodySmall),
                        if (e.source != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              e.source!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: e.verified == true
                                    ? scheme.primary
                                    : scheme.tertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static IconData _icon(BrainKind k) => switch (k) {
    BrainKind.safety => Icons.shield_outlined,
    BrainKind.differential => Icons.account_tree_outlined,
    BrainKind.nextStep => Icons.arrow_forward,
    BrainKind.missingData => Icons.edit_note,
  };
}
