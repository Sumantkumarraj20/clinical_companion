import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/bedside/widgets/quick_action_sheet.dart';

/// Shell that hosts the app's four primary destinations.
///
/// Replaces the previous 8-item rail/bottom-nav with a Material 3
/// [NavigationBar] of four *workload* destinations. The clinical tools that
/// used to occupy their own tabs (labs, drugs, vitals, wiki, data) are still
/// one tap away, but they no longer compete for the thumb-zone with the
/// destinations a clinician actually moves between.
class MainNavigationScaffold extends ConsumerWidget {
  const MainNavigationScaffold({required this.child, super.key});

  final Widget child;

  /// The four primary destinations. Paths must match the router's ShellRoute
  /// children; `location` is used to resolve the selected index when the
  /// current route is a nested one (e.g. a patient timeline).
  static const destinations = <_Destination>[
    _Destination(
      path: '/dashboard',
      location: '/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Home',
    ),
    _Destination(
      path: '/patients',
      location: '/patients',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      label: 'Patients',
    ),
    _Destination(
      path: '/drugs',
      location: '/drugs',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Reference',
    ),
    _Destination(
      path: '/research',
      location: '/research',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Research',
    ),
  ];

  static int _indexFor(String location) {
    // Longest-prefix wins so `/patients/:id` still highlights Patients.
    var best = 0;
    var bestLength = -1;
    for (var i = 0; i < destinations.length; i++) {
      final destination = destinations[i];
      if (location.startsWith(destination.location) &&
          destination.location.length > bestLength) {
        best = i;
        bestLength = destination.location.length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFor(location);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    // The FAB is the single capture affordance. It is hidden on the wide
    // layout, where the navigation rail already exposes the tools inline and a
    // floating button would overlap content.
    final fab = !isWide
        ? FloatingActionButton(
            onPressed: () => showQuickActionSheet(context),
            tooltip: 'Quick actions',
            elevation: 6,
            child: const Icon(Icons.add),
          )
        : null;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  context.go(destinations[index].path),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: IconButton(
                  tooltip: 'Quick actions',
                  onPressed: () => showQuickActionSheet(context),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ),
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(destinations[index].path),
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
              tooltip: destination.label,
            ),
        ],
      ),
    );
  }
}

@immutable
class _Destination {
  const _Destination({
    required this.path,
    required this.location,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final String location;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
