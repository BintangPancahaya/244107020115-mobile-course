import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/db_factory.dart';
import 'data/repositories/note_repository.dart';
import 'data/sync.dart';
import 'main.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';
import 'router.dart';

/// Entrypoint KHUSUS dokumentasi screenshot di Chrome:
///   flutter run -t lib/screenshot_main.dart --dart-define=SCENE=NAMA_SCENE
/// Kondisi awal disiapkan lewat repository/provider ASLI (SQLite WASM +
/// SharedPreferences sungguhan), lalu aplikasi yang sama dengan main.dart
/// dijalankan. Scene: settings_light, settings_dark, notes, notes_offline,
/// add_dialog, dirty_before, dirty_after.
const scene = String.fromEnvironment('SCENE', defaultValue: 'notes');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDbFactory();
  final container = ProviderContainer(overrides: [
    initialTabProvider.overrideWithValue(scene.startsWith('settings') ? 2 : 0),
  ]);

  await container.read(prefsRepositoryProvider).setDarkMode(
        scene == 'settings_dark',
      );

  if (!scene.startsWith('settings')) {
    final repo = container.read(noteRepositoryProvider);
    if ((await repo.fetchNotes()).isEmpty) {
      await repo.addNote(
          title: 'Belanja mingguan', body: 'Susu, telur, roti, sayur');
      await repo.addNote(
          title: 'Tugas Pemrograman Mobile',
          body: 'Praktikum Minggu 5: local storage & offline-first');
    }
  }
  if (scene == 'notes_offline' || scene == 'dirty_before') {
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
