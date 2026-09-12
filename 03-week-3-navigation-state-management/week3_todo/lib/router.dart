import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/product_page.dart';
import 'pages/stats_page.dart';
import 'pages/todo_detail_page.dart';
import 'pages/todo_page.dart';

/// Lokasi awal bisa diatur lewat --dart-define=START=/stats (default '/').
const _startLocation = String.fromEnvironment('START', defaultValue: '/');

GoRouter createRouter({String? initialLocation}) => GoRouter(
      initialLocation: initialLocation ?? _startLocation,
      routes: [
        // Halaman dengan NavigationBar: / (daftar) dan /stats (statistik).
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              ScaffoldWithNavBar(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/', builder: (_, _) => const TodoPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/stats', builder: (_, _) => const StatsPage()),
            ]),
          ],
        ),
        // Halaman penuh tanpa NavigationBar, dibuka dengan context.push.
        GoRoute(
          path: '/todo/:id',
          builder: (context, state) => TodoDetailPage(
            id: int.tryParse(state.pathParameters['id']!) ?? -1,
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (_, _) => const ProductPage(),
        ),
      ],
    );

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.checklist), label: 'Tugas'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart), label: 'Statistik'),
          ],
        ),
      );
}
