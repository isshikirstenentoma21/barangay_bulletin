import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/announcement.dart';
import 'models/issue_report.dart';
import 'screens/archive_screen.dart';
import 'screens/announcements_list_screen.dart';
import 'screens/reports_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive
    ..registerAdapter(AnnouncementAdapter())
    ..registerAdapter(IssueReportAdapter());
  await Hive.openBox<Announcement>('announcements');
  await Hive.openBox<IssueReport>('issue_reports');
  runApp(const BarangayBulletinApp());
}

class BarangayBulletinApp extends StatelessWidget {
  const BarangayBulletinApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1D6F62);

    return MaterialApp(
      title: 'Barangay Bulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(centerTitle: false),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _navigatorKeys = List.generate(3, (_) => GlobalKey<NavigatorState>());
  int _selectedIndex = 0;

  Future<bool> _handleBack() async {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }
    return true;
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _TabNavigator(
              navigatorKey: _navigatorKeys[0],
              child: const AnnouncementsListScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[1],
              child: const ReportsListScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[2],
              child: const ArchiveScreen(),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign),
              label: 'Announcements',
            ),
            NavigationDestination(
              icon: Icon(Icons.report_problem_outlined),
              selectedIcon: Icon(Icons.report_problem),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.archive_outlined),
              selectedIcon: Icon(Icons.archive),
              label: 'Archive',
            ),
          ],
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
    );
  }
}
