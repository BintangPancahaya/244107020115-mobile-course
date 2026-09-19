import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/format.dart';
import '../data/prefs.dart';
import '../data/sync.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

/// Waktu terakhir aplikasi dibuka (SharedPreferences).
final lastOpenedProvider = FutureProvider<String?>(
  (ref) => ref.watch(prefsRepositoryProvider).getLastOpened(),
);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);
    final offline = ref.watch(forceOfflineProvider);
    final isDark = dark.value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Tema gelap'),
            subtitle: Text(isDark
                ? 'Aktif - tersimpan di SharedPreferences'
                : 'Nonaktif - tersimpan di SharedPreferences'),
            value: isDark,
            onChanged: dark.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Terakhir dibuka'),
            subtitle: Text(lastOpened.when(
              data: (v) {
                final d = v == null ? null : DateTime.tryParse(v);
                return d == null ? '-' : formatDateTime(d);
              },
              loading: () => 'Memuat...',
              error: (e, _) => 'Gagal membaca preferensi',
            )),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_off),
            title: const Text('Paksa mode offline'),
            subtitle: const Text(
                'Simulasi offline deterministik untuk demo dan testing'),
            value: offline,
            onChanged: (v) => ref.read(forceOfflineProvider.notifier).set(v),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Bintang Pancahaya P'),
            subtitle: Text('NIM 244107020115'),
          ),
        ],
      ),
    );
  }
}
