import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/announcement.dart';
import 'announcement_form_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  final String announcementId;

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final _box = Hive.box<Announcement>('announcements');

  Announcement? get _announcement => _box.get(widget.announcementId);

  Future<void> _edit(Announcement announcement) async {
    final result = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(
        builder: (_) => AnnouncementFormScreen(announcement: announcement),
      ),
    );
    if (result == null) return;
    await _box.put(result.id, result);
    setState(() {});
  }

  Future<void> _softDelete(Announcement announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive announcement?'),
        content: const Text('This moves the announcement to Archive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    announcement
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await announcement.save();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final announcement = _announcement;
    if (announcement == null) {
      return const Scaffold(body: Center(child: Text('Announcement not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => _edit(announcement),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Archive',
            onPressed: () => _softDelete(announcement),
            icon: const Icon(Icons.archive_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Chip(label: Text(announcement.category)),
              const SizedBox(width: 8),
              if (announcement.isPinned)
                const Chip(
                  avatar: Icon(Icons.push_pin, size: 18),
                  label: Text('Pinned'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(DateFormat.yMMMMd().add_jm().format(announcement.datePosted)),
          const Divider(height: 32),
          Text(
            announcement.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
