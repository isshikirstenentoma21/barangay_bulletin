import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/announcement.dart';
import '../models/issue_report.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _announcementBox = Hive.box<Announcement>('announcements');
  final _reportBox = Hive.box<IssueReport>('issue_reports');

  List<_ArchiveEntry> get _items {
    final announcements = _announcementBox.values
        .where((item) => item.isDeleted)
        .map(_ArchiveEntry.announcement);
    final reports = _reportBox.values
        .where((item) => item.isDeleted)
        .map(_ArchiveEntry.report);
    final items = [...announcements, ...reports];
    items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    return items;
  }

  Future<void> _restore(_ArchiveEntry entry) async {
    if (entry.announcement != null) {
      final item = entry.announcement!;
      item
        ..isDeleted = false
        ..deletedAt = null;
      await item.save();
    } else {
      final item = entry.report!;
      item
        ..isDeleted = false
        ..deletedAt = null;
      await item.save();
    }
    setState(() {});
  }

  Future<void> _deleteForever(_ArchiveEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete forever?'),
        content: const Text('This permanently removes the item from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (entry.announcement != null) {
      await entry.announcement!.delete();
    } else {
      await entry.report!.delete();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(item.isAnnouncement ? Icons.campaign : Icons.report_problem),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item.typeLabel} • deleted ${DateFormat.yMMMd().add_jm().format(item.deletedAt)}',
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _restore(item),
                              icon: const Icon(Icons.restore),
                              label: const Text('Restore'),
                            ),
                            TextButton.icon(
                              onPressed: () => _deleteForever(item),
                              icon: const Icon(Icons.delete_forever_outlined),
                              label: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemCount: items.length,
            ),
    );
  }
}

class _ArchiveEntry {
  _ArchiveEntry.announcement(this.announcement)
      : report = null,
        title = announcement!.title,
        typeLabel = 'Announcement',
        deletedAt = announcement.deletedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  _ArchiveEntry.report(this.report)
      : announcement = null,
        title = report!.title,
        typeLabel = 'Report',
        deletedAt = report.deletedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final Announcement? announcement;
  final IssueReport? report;
  final String title;
  final String typeLabel;
  final DateTime deletedAt;

  bool get isAnnouncement => announcement != null;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Archive is empty', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Archived announcements and reports will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
