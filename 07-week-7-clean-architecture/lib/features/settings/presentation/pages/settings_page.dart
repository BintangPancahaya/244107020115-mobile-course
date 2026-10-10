import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format.dart';
import '../../../../shared/connectivity.dart';
import '../providers/settings_providers.dart';

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
              data: formatDateTimeOrDash,
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
