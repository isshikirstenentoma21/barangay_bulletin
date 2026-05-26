import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/issue_report.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _box = Hive.box<IssueReport>('issue_reports');

  IssueReport? get _report => _box.get(widget.reportId);

  Future<void> _edit(IssueReport report) async {
    final result = await Navigator.of(context).push<IssueReport>(
      MaterialPageRoute(builder: (_) => ReportFormScreen(report: report)),
    );
    if (result == null) return;
    await _box.put(result.id, result);
    setState(() {});
  }

  Future<void> _softDelete(IssueReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive report?'),
        content: const Text('This moves the report to Archive.'),
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
    report
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await report.save();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    if (report == null) {
      return const Scaffold(body: Center(child: Text('Report not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => _edit(report),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Archive',
            onPressed: () => _softDelete(report),
            icon: const Icon(Icons.archive_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(report.category)),
              Chip(label: Text(report.status)),
            ],
          ),
          const SizedBox(height: 12),
          Text(report.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(DateFormat.yMMMMd().add_jm().format(report.dateReported)),
          const Divider(height: 32),
          Text(
            report.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
