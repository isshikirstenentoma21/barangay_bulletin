import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/announcement.dart';

class AnnouncementFormScreen extends StatefulWidget {
  const AnnouncementFormScreen({super.key, this.announcement});

  final Announcement? announcement;

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late String _category;
  late bool _isPinned;

  bool get _isEditing => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    final announcement = widget.announcement;
    _titleController = TextEditingController(text: announcement?.title ?? '');
    _bodyController = TextEditingController(text: announcement?.body ?? '');
    _category = announcement?.category ?? announcementCategories.first;
    _isPinned = announcement?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.announcement;
    final result = existing == null
        ? Announcement(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            category: _category,
            datePosted: DateTime.now(),
            isPinned: _isPinned,
          )
        : existing.copyWith(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            category: _category,
            isPinned: _isPinned,
          );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Announcement' : 'New Announcement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Title is required.';
                if (text.length > 120) return 'Maximum is 120 characters.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: announcementCategories
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bodyController,
              minLines: 5,
              maxLines: 9,
              decoration: const InputDecoration(labelText: 'Body'),
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) return 'Body is required.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pin to top'),
              value: _isPinned,
              onChanged: (value) => setState(() => _isPinned = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
