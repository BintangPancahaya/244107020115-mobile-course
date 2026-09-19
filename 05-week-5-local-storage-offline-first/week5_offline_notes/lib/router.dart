import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Tab awal (0 Catatan, 1 Posts, 2 Pengaturan); bisa diatur lewat
/// --dart-define=START_TAB=2.
final initialTabProvider =
    Provider<int>((ref) => const int.fromEnvironment('START_TAB'));

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeShell()),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) => NoteDetailPage(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      ),
    ),
  ],
);

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late int _index = ref.read(initialTabProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(prefsRepositoryProvider).markOpenedNow();
      ref.invalidate(lastOpenedProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [NotesPage(), PostsPage(), SettingsPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.note_outlined),
              selectedIcon: Icon(Icons.note),
              label: 'Catatan'),
          NavigationDestination(
              icon: Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article),
              label: 'Posts'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Pengaturan'),
        ],
      ),
    );
  }
}
