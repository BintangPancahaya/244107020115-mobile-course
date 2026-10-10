import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/home_shell.dart';
import 'features/notes/presentation/providers/notes_providers.dart';
import 'features/notes/presentation/widgets/note_actions.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'main.dart';
import 'routes.dart';
import 'shared/connectivity.dart';
import 'shared/database/db_factory.dart';

/// Entrypoint KHUSUS screenshot after-refactor di Chrome (scene sama dengan
/// Minggu 5 agar before/after bisa dibandingkan):
///   flutter run -t lib/screenshot_main.dart --dart-define=SCENE=NAMA_SCENE
/// Kondisi disiapkan lewat provider/use case ASLI hasil refactor.
const scene = String.fromEnvironment('SCENE', defaultValue: 'notes');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDbFactory();
  final container = ProviderContainer(overrides: [
    initialTabProvider.overrideWithValue(scene.startsWith('settings') ? 2 : 0),
  ]);

  await container
      .read(settingsRepositoryProvider)
      .setDarkMode(scene == 'settings_dark');

  if (!scene.startsWith('settings')) {
    final existing = await container.read(getNotesProvider).call();
    if (existing.notes.isEmpty) {
      final add = container.read(addNoteProvider);
      await add(title: 'Belanja mingguan', body: 'Susu, telur, roti, sayur');
      await add(
          title: 'Tugas Pemrograman Mobile',
          body: 'Praktikum Minggu 5: local storage & offline-first');
    }
  }
  if (scene == 'dirty_before') {
    container.read(forceOfflineProvider.notifier).set(true);
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final ctx = rootNavigatorKey.currentState?.overlay?.context;
    if (ctx == null || !ctx.mounted) return;
    if (scene == 'add_dialog') {
      showAddNoteDialog(ctx,
          initialTitle: 'Jadwal kuliah',
          initialBody: 'Senin 07.00 - Pemrograman Mobile');
    } else if (scene == 'dirty_after') {
      await syncNow(ctx);
    }
  });
}
