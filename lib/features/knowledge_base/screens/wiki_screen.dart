import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';

class WikiScreen extends ConsumerStatefulWidget {
  const WikiScreen({super.key});

  @override
  ConsumerState<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends ConsumerState<WikiScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  WikiEntry? _selected;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) ref.read(wikiSearchQueryProvider.notifier).update(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(wikiEntriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Second Memory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _capture(context),
        icon: const Icon(Icons.add),
        label: const Text('Capture pearl'),
      ),
      body: entries.when(
        loading: () => const ShimmerLoading(),
        error: (error, stack) =>
            Center(child: Text('Unable to load notes: $error')),
        data: (items) {
          if (_selected != null &&
              items.every((item) => item.id != _selected!.id)) {
            _selected = null;
          }
          final list = ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                selected: item.id == _selected?.id,
                title: Text(
                  item.topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.tags.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => setState(() => _selected = item),
              );
            },
          );
          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final search = Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _search,
                  onChanged: _onSearch,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search topics, tags, or clinical pearls',
                    suffixIcon: Icon(Icons.tune),
                  ),
                ),
              );
              final master = Column(
                children: [
                  search,
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text('No saved pearls'))
                        : list,
                  ),
                ],
              );
              final detail = _selected == null
                  ? const Center(child: Text('Select a note to read it'))
                  : _WikiDetail(entry: _selected!);
              return wide
                  ? Row(
                      children: [
                        SizedBox(width: 320, child: master),
                        const VerticalDivider(width: 1),
                        Expanded(child: detail),
                      ],
                    )
                  : Column(
                      children: [
                        search,
                        Expanded(child: _selected == null ? list : detail),
                      ],
                    );
            },
          );
        },
      ),
    );
  }

  Future<void> _capture(BuildContext context) async {
    final draft = await showDialog<_WikiDraft>(
      context: context,
      builder: (context) => const _CaptureDialog(),
    );
    if (draft == null) return;
    final ownerId = ref.read(currentOwnerIdProvider);
    try {
      await ref
          .read(clinicalDaoProvider)
          .insertWikiEntry(
            PersonalWikiCompanion.insert(
              ownerId: ownerId,
              topic: draft.topic,
              markdownContent: Value(draft.content),
              tags: Value(draft.tags),
              departmentRelevance: Value(draft.departments),
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved offline and queued for sync.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save note: $error')));
      }
    }
  }
}

class _WikiDetail extends StatelessWidget {
  const _WikiDetail({required this.entry});
  final WikiEntry entry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.topic, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [for (final tag in entry.tags) Chip(label: Text(tag))],
        ),
        const Divider(height: 32),
        MarkdownBody(data: entry.markdownContent),
      ],
    ),
  );
}

class _WikiDraft {
  const _WikiDraft({
    required this.topic,
    required this.content,
    required this.tags,
    required this.departments,
  });
  final String topic;
  final String content;
  final List<String> tags;
  final List<String> departments;
}

class _CaptureDialog extends StatefulWidget {
  const _CaptureDialog();
  @override
  State<_CaptureDialog> createState() => _CaptureDialogState();
}

class _CaptureDialogState extends State<_CaptureDialog> {
  final _topic = TextEditingController();
  final _content = TextEditingController();
  final _tags = TextEditingController();
  final _departments = <String>{};
  static const _departmentOptions = [
    'Medicine',
    'OBGYN',
    'Pediatrics',
    'Surgery',
    'Plastic Surgery',
    'Psychiatry',
  ];

  @override
  void dispose() {
    _topic.dispose();
    _content.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Capture clinical pearl'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _topic,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _content,
              minLines: 6,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Markdown content',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Relevant departments',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Wrap(
              children: [
                for (final department in _departmentOptions)
                  FilterChip(
                    label: Text(department),
                    selected: _departments.contains(department),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _departments.add(department);
                      } else {
                        _departments.remove(department);
                      }
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final topic = _topic.text.trim();
          if (topic.isEmpty || _content.text.trim().isEmpty) return;
          Navigator.pop(
            context,
            _WikiDraft(
              topic: topic,
              content: _content.text.trim(),
              tags: _tags.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList(growable: false),
              departments: _departments.toList(growable: false),
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}
