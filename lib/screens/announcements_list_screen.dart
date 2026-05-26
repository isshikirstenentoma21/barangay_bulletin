import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/announcement.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  final _box = Hive.box<Announcement>('announcements');
  String _category = 'All';
  bool _pinnedOnly = false;

  List<Announcement> get _announcements {
    final items = _box.values.where((item) {
      final categoryMatches = _category == 'All' || item.category == _category;
      return !item.isDeleted &&
          categoryMatches &&
          (!_pinnedOnly || item.isPinned);
    }).toList();
    items.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.datePosted.compareTo(a.datePosted);
    });
    return items;
  }

  Future<void> _createAnnouncement() async {
    final result = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(builder: (_) => const AnnouncementFormScreen()),
    );
    if (result == null) return;
    await _box.put(result.id, result);
    setState(() {});
  }

  Future<void> _openDetail(Announcement announcement) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AnnouncementDetailScreen(announcementId: announcement.id),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _announcements;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'ANNOUNCEMENTS',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        actions: [
          IconButton(
            tooltip: _pinnedOnly ? 'Show all' : 'Pinned only',
            onPressed: () => setState(() => _pinnedOnly = !_pinnedOnly),
            icon: Icon(_pinnedOnly ? Icons.push_pin : Icons.push_pin_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            value: _category,
            values: const ['All', ...announcementCategories],
            onChanged: (value) => setState(() => _category = value),
          ),
          Expanded(
            child: items.isEmpty
                ? const _EmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'No announcements yet',
                    message: 'Post a barangay update, event, or advisory.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _HoverAnnouncementCard(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: const Color(0xFF374151),
                            child: Icon(
                              item.isPinned ? Icons.push_pin : Icons.campaign,
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.category} • ${DateFormat.yMMMd().format(item.datePosted)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetail(item),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemCount: items.length,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAnnouncement,
        icon: const Icon(Icons.add),
        label: const Text('Post'),
      ),
    );
  }
}

class _HoverAnnouncementCard extends StatefulWidget {
  const _HoverAnnouncementCard({required this.child});

  final Widget child;

  @override
  State<_HoverAnnouncementCard> createState() => _HoverAnnouncementCardState();
}

class _HoverAnnouncementCardState extends State<_HoverAnnouncementCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFD1D5DB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF4B5563)
                : const Color(0xFFD1D5DB),
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = values[index];
          return ChoiceChip(
            label: Text(item),
            selected: value == item,
            onSelected: (_) => onChanged(item),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: values.length,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
