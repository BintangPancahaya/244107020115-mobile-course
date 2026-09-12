import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart';
import 'providers/stats_provider.dart';
import 'providers/todo_provider.dart';

/// Entrypoint KHUSUS dokumentasi screenshot di Chrome:
///   flutter run -t lib/screenshot_main.dart --dart-define=SCENE=NAMA_SCENE
/// Chrome tidak bisa diklik saat komputer dikendalikan jarak jauh, jadi
/// kondisi layar disiapkan lewat notifier ASLI (TodoListNotifier) dan
/// override provider simulasi (delay/acak) yang sama dengan unit test.
/// Scene: todo, detail, stats_loading, stats_error, stats_success.
const scene = String.fromEnvironment('SCENE', defaultValue: 'todo');

void main() {
  final container = ProviderContainer(overrides: [
    if (scene == 'stats_loading')
      statsDelayProvider.overrideWithValue(const Duration(hours: 1)),
    if (scene == 'stats_error') statsRandomProvider.overrideWithValue(() => 0.1),
    if (scene == 'stats_success')
      statsRandomProvider.overrideWithValue(() => 0.9),
  ]);

  final todos = container.read(todoListProvider.notifier);
  todos
    ..add('Belajar GoRouter')
    ..add('Belajar Riverpod')
    ..add('Kerjakan laporan Minggu 3');
  todos.toggle(container.read(todoListProvider).first.id);

  final location = switch (scene) {
    'detail' => '/todo/0',
    'stats_loading' || 'stats_error' || 'stats_success' => '/stats',
    _ => '/',
  };

  runApp(UncontrolledProviderScope(
    container: container,
    child: MyApp(initialLocation: location),
  ));
}
