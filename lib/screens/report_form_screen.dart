import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/issue_report.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, this.report});

  final IssueReport? report;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _category;
  late String _status;

  bool get _isEditing => widget.report != null;

  @override
  void initState() {
    super.initState();
    final report = widget.report;
    _titleController = TextEditingController(text: report?.title ?? '');
    _descriptionController = TextEditingController(text: report?.description ?? '');
    _category = report?.category ?? reportCategories.first;
    _status = report?.status ?? reportStatuses.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.report;
    final result = existing == null
        ? IssueReport(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            status: _status,
            dateReported: DateTime.now(),
          )
        : existing.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            status: _status,
          );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Report' : 'New Report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) return 'Title is required.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: reportCategories
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: reportStatuses
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 5,
              maxLines: 9,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return 'Description is required.';
                }
                return null;
              },
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
