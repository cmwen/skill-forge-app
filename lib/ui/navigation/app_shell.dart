import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/generate/generate_screen.dart';
import '../screens/stats/progress_screen.dart';
import '../screens/settings/more_screen.dart';
import '../theme/app_theme.dart';

/// The main app shell with bottom navigation.
///
/// Contains the four primary navigation destinations:
/// - Goals (home)
/// - Generate
/// - Progress
/// - More
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final List<Widget> _screens = const [
    GoalsScreen(),
    GenerateScreen(),
    ProgressScreen(),
    MoreScreen(),
  ];

  void _onDestinationSelected(int index) {
    context.read<NavigationProvider>().navigateToIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    
    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationProvider.selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Generate',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
