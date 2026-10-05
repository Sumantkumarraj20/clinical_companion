import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';

/// The unified knowledge flywheel.
///
/// Sprint 16 — merges the two halves of "the clinician's second brain":
///
///  * **Case Reflections** — the clinician's own private reasoning, newest
///    first. Owner-scoped, never synced, never exported into cohorts.
///  * **Clinical Guidelines** — the personal wiki, the durable reference half.
///
/// The connective tissue is `#hashtags`: a reflection tagged `#hyponatremia`
/// sits next to the hyponatremia guideline, so recalling the guideline also
/// surfaces the clinician's own past reasoning on the same problem.
class KnowledgeHubScreen extends ConsumerStatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  ConsumerState<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends ConsumerState<KnowledgeHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Hub'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(
              icon: Icon(Icons.psychology_outlined),
              text: 'Case Reflections',
            ),
            Tab(
              icon: Icon(Icons.menu_book_outlined),
              text: 'Clinical Guidelines',
            ),
            Tab(icon: Icon(Icons.visibility_outlined), text: 'Blind Spots'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [_ReflectionsTab(), _GuidelinesTab(), _BlindSpotsTab()],
      ),
    );
  }
}

class _ReflectionsTab extends ConsumerWidget {
  const _ReflectionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);
    return FutureBuilder<List<ClinicalLearningLog>>(
      future: dao.getAllReflections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data ?? const <ClinicalLearningLog>[];
        if (rows.isEmpty) {
          return const _HubEmpty(
            icon: Icons.psychology_outlined,
            title: 'No reflections yet',
            body:
                'Log what you were thinking after a case. It stays private, '
                'and it is how you calibrate over a career.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          itemCount: rows.length,
          itemBuilder: (context, index) => _ReflectionCard(log: rows[index]),
        );
      },
    );
  }
}

class _BlindSpotsTab extends ConsumerWidget {
  const _BlindSpotsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);
    return FutureBuilder(
      future: dao.getFrequentAcceptedClinicalAudits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _HubEmpty(
            icon: Icons.error_outline,
            title: 'Could not load audit history',
            body: 'Accepted ClinCom suggestions are stored locally.',
          );
        }
        final rows = snapshot.data ?? const [];
        if (rows.isEmpty) {
          return const _HubEmpty(
            icon: Icons.visibility_outlined,
            title: 'No patterns yet',
            body:
                'Accepted chart-audit suggestions will appear here to guide '
                'your future reading and exam preparation.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                'My Clinical Blind Spots',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final item in rows)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(item.title),
                  subtitle: Text(
                    '${_auditCategoryLabel(item.suggestionType)} · '
                    'accepted ${item.acceptedCount} '
                    '${item.acceptedCount == 1 ? 'time' : 'times'}',
                  ),
                  isThreeLine: true,
                ),
              ),
          ],
        );
      },
    );
  }

  static String _auditCategoryLabel(String type) => switch (type) {
    'missing_investigation' => 'Missed investigations',
    'management_suggestion' => 'Management steps',
    'differential_diagnosis' => 'Differential diagnosis',
    'warning' => 'Safety warnings',
    _ => 'Clinical suggestion',
  };
}

class _ReflectionCard extends ConsumerWidget {
  const _ReflectionCard({required this.log});

  final ClinicalLearningLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dao = ref.watch(clinicalDaoProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Confidence is a plain number, not a coloured badge: a "high
                // confidence" pill would read as a clinical grade.
                Text(
                  'Confidence ${log.diagnosisConfidenceScore}/10',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  DateTimeUtils.relative(log.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            if (log.decisionRationale.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                log.decisionRationale.trim(),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (log.clinicalTakeaway.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                log.clinicalTakeaway.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (log.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              // Tapping a tag cross-links into the wiki half of the hub.
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in log.tags)
                    ActionChip(
                      label: Text('#$tag'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        final guidelines = await dao.searchWikiEntries(
                          query: tag,
                          limit: 5,
                        );
                        if (!context.mounted) return;
                        await showModalBottomSheet<void>(
                          context: context,
                          builder: (_) =>
                              _TagWikiSheet(tag: tag, guidelines: guidelines),
                        );
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Cross-link sheet: guidelines matching a tag.
class _TagWikiSheet extends StatelessWidget {
  const _TagWikiSheet({required this.tag, required this.guidelines});

  final String tag;
  final List<PersonalWikiEntry> guidelines;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('#$tag', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              guidelines.isEmpty
                  ? 'No guideline matches this tag yet.'
                  : 'Related clinical guidelines',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final entry in guidelines)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.article_outlined),
                      title: Text(entry.topic),
                      subtitle: Text(
                        entry.markdownContent,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidelinesTab extends ConsumerWidget {
  const _GuidelinesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(wikiEntriesProvider);
    return entries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _HubEmpty(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load guidelines',
        body: 'The wiki is stored on this device.',
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return const _HubEmpty(
            icon: Icons.menu_book_outlined,
            title: 'No guidelines yet',
            body:
                'Write protocols and teaching notes so they are here when '
                'the ward is busy.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final entry = rows[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(entry.topic),
                subtitle: Text(
                  entry.markdownContent,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _HubEmpty extends StatelessWidget {
  const _HubEmpty({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
