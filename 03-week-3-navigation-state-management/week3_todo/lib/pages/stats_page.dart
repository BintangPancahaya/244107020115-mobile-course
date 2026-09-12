import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../providers/todo_provider.dart';

/// Halaman statistik (/stats). ConsumerWidget yang menangani ketiga state
/// AsyncValue: loading (spinner), error (pesan + retry), success (ListView).
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch hanya di build: halaman rebuild saat state berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            // Callback memakai ref, bukan ref.watch.
            onPressed: () => ref.invalidate(statsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        // Saat "Coba lagi" ditekan, tampilkan spinner lagi (bukan error lama).
        skipLoadingOnRefresh: false,
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Mengambil statistik...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48),
                const SizedBox(height: 12),
                Text('$err', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(statsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => _StatsView(stats: stats),
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.stats});
  final TodoStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Total tugas', value: stats.total, icon: Icons.list),
      (label: 'Selesai', value: stats.done, icon: Icons.check_circle),
      (label: 'Belum selesai', value: stats.pending, icon: Icons.pending),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progres ${(stats.progress * 100).round()}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: stats.progress),
            ],
          ),
        ),
        Expanded(
          // Success: ListView 3 item.
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  trailing: Text('${item.value}',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
