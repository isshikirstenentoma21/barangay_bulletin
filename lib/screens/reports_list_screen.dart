import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/issue_report.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final _box = Hive.box<IssueReport>('issue_reports');
  String _category = 'All';
  String _status = 'All';

  List<IssueReport> get _reports {
    final items = _box.values.where((item) {
      final categoryMatches = _category == 'All' || item.category == _category;
      final statusMatches = _status == 'All' || item.status == _status;
      return !item.isDeleted && categoryMatches && statusMatches;
    }).toList();
    items.sort((a, b) => b.dateReported.compareTo(a.dateReported));
    return items;
  }

  Future<void> _createReport() async {
    final result = await Navigator.of(context).push<IssueReport>(
      MaterialPageRoute(builder: (_) => const ReportFormScreen()),
    );
    if (result == null) return;
    await _box.put(result.id, result);
    setState(() {});
  }

  Future<void> _openDetail(IssueReport report) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: report.id)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _reports;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          _FilterBar(
            value: _status,
            values: const ['All', ...reportStatuses],
            onChanged: (value) => setState(() => _status = value),
          ),
          _FilterBar(
            value: _category,
            values: const ['All', ...reportCategories],
            onChanged: (value) => setState(() => _category = value),
          ),
          Expanded(
            child: items.isEmpty
                ? const _EmptyState(
                    icon: Icons.report_problem_outlined,
                    title: 'No reports yet',
                    message: 'Log road, water, power, safety, or other concerns.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(_statusIcon(item.status))),
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.category} • ${item.status} • ${DateFormat.yMMMd().format(item.dateReported)}',
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
        onPressed: _createReport,
        icon: const Icon(Icons.add),
        label: const Text('Report'),
      ),
    );
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'Resolved' => Icons.check_circle_outline,
      'In Progress' => Icons.timelapse,
      _ => Icons.pending_actions,
    };
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
      height: 52,
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
