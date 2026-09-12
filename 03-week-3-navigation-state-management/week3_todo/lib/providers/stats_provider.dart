import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_provider.dart';

// AI Challenge Minggu 3: StatsPage dengan AsyncNotifierProvider yang
// mensimulasikan pengambilan data statistik (delay 2 detik, gagal 30%).

/// Peluang simulasi gagal (30%).
const statsFailureRate = 0.3;

/// Lama simulasi network. Dibuat provider agar test bisa memakai
/// Duration.zero, bukan menunggu 2 detik sungguhan.
final statsDelayProvider =
    Provider<Duration>((ref) => const Duration(seconds: 2));

/// Sumber angka acak 0..1. Dibuat provider agar test bisa menentukan
/// hasil (gagal / sukses) secara deterministik, bukan acak.
final statsRandomProvider =
    Provider<double Function()>((ref) => Random().nextDouble);

/// Exception dengan pesan yang siap ditampilkan ke pengguna.
class StatsException implements Exception {
  const StatsException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Notifier statistik. Data dihitung dari [todoStatsProvider] yang sudah
/// ada (tidak membuat perhitungan/provider duplikat), lalu "diambil" lewat
/// simulasi network.
class StatsNotifier extends AsyncNotifier<TodoStats> {
  @override
  Future<TodoStats> build() async {
    // ref.watch dipanggil SEBELUM await: build() otomatis diulang saat
    // daftar tugas berubah, dan aturan Riverpod 3 (tidak boleh watch setelah
    // async gap) terpenuhi.
    final stats = ref.watch(todoStatsProvider);
    final delay = ref.watch(statsDelayProvider);
    final roll = ref.watch(statsRandomProvider)();

    await Future<void>.delayed(delay); // simulasi network

    // 30% kemungkinan gagal. Exception yang dilempar di build() otomatis
    // menjadi AsyncError tanpa try/catch manual.
    if (roll < statsFailureRate) {
      throw const StatsException('Gagal mengambil statistik dari server.');
    }
    return stats;
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, TodoStats>(
  StatsNotifier.new,
  // Riverpod 3 me-retry provider yang error secara otomatis; dimatikan agar
  // UI error + tombol "Coba lagi" yang mengontrol percobaan ulang.
  retry: (retryCount, error) => null,
);
