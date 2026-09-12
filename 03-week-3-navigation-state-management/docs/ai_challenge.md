# AI Challenge - Minggu 3: StatsPage dengan AsyncNotifierProvider

## Prompt yang digunakan
```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```
AI yang dipakai: Claude (AI coding assistant).

## Output awal AI (draf pertama, sebelum disesuaikan dengan project)
```dart
class StatsNotifier extends AsyncNotifier<List<String>> {
  final _random = Random();

  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi network
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal memuat statistik');
    }
    return ['Total tugas: 12', 'Selesai: 8', 'Belum selesai: 4'];
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Error: $err'),
            ElevatedButton(
              onPressed: () => ref.read(statsProvider.notifier).retry(),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(title: Text(items[i])),
        ),
      ),
    );
  }
}

// test
test('statsProvider menghasilkan 3 item', () async {
  final container = ProviderContainer();
  final items = await container.read(statsProvider.future);
  expect(items.length, 3);
});
```

## Hasil verifikasi (AI Verification Checklist)
| No | Poin pemeriksaan | Hasil | Temuan |
| :-: | :--- | :-: | :--- |
| 1 | State diubah immutable (tanpa `state.add()` / mutasi list)? | Lolos | Draf tidak memutasi list; state hanya diganti lewat `AsyncValue`. |
| 2 | `ref.watch` hanya di `build`, `ref.read` di callback? | Lolos dengan catatan | Pemakaian `watch`/`read` sudah benar, tetapi `retry()` memanggil `build()` secara manual lewat `AsyncValue.guard(build)`, sehingga melewati lifecycle provider (dependensi tidak dihitung ulang). |
| 3 | Ketiga state AsyncValue ditangani? | Lolos dengan catatan | Loading/error/success ada. Namun di Riverpod 3: (a) provider yang error otomatis di-retry dengan backoff sehingga UI lama tertahan di loading; (b) saat refresh, `.when` default tetap menampilkan error lama, jadi spinner tidak muncul ketika retry ditekan. |
| 4 | Tipe provider eksplisit dan tidak duplikat? | **Gagal** | Tipe eksplisit, tetapi data statistik di-hardcode (`Total tugas: 12`) padahal project sudah punya `todoStatsProvider`. Ada dua sumber statistik yang bisa tidak sinkron. |
| 5 | API Riverpod versi lama (`StateProvider`, `StateNotifierProvider`, `Consumer` bertingkat)? | Lolos | Draf sudah memakai `AsyncNotifier` + `ConsumerWidget`. |
| 6 | `flutter analyze` & `flutter test` lolos? | **Gagal** | `Random()` di dalam notifier tidak bisa dikendalikan test: test draf akan gagal sekitar 30% run dan selalu menunggu 2 detik sungguhan. Kasus gagal dan retry tidak diuji sama sekali. |

## Perbaikan yang dilakukan
| No | Masalah | Perbaikan (kode final) |
| :-: | :--- | :--- |
| 1 | Data statistik hardcode / duplikat | `StatsNotifier` (`lib/providers/stats_provider.dart`) membaca `todoStatsProvider` yang sudah ada dan mengembalikan `TodoStats`; tampilan 3 item dibangun dari model itu. |
| 2 | `Random()` dan delay tidak bisa diuji | Dibuat provider `statsRandomProvider` dan `statsDelayProvider`; test meng-override keduanya (angka acak ditentukan, delay `Duration.zero`). |
| 3 | `retry()` memanggil `build()` manual | Dihapus; tombol **Coba lagi** memakai `ref.invalidate(statsProvider)` sehingga Riverpod menjalankan ulang `build()` dengan benar. |
| 4 | Auto-retry Riverpod 3 menahan UI di loading | `retry: (retryCount, error) => null` pada `statsProvider`. |
| 5 | Spinner tidak muncul saat retry | `statsAsync.when(skipLoadingOnRefresh: false, ...)`. |
| 6 | Pesan error mentah `Error: Exception: ...` | `StatsException` dengan `toString()` berisi pesan ramah: "Gagal mengambil statistik dari server." |
| 7 | Bentrok dengan halaman statistik refactoring | `StatsPage` menggantikan halaman `/stats` lama sehingga hanya ada satu halaman statistik di NavigationBar; tampilan progres tetap dipertahankan. |
| 8 | `watch` setelah `await` (larangan Riverpod 3) | Semua `ref.watch` diletakkan sebelum `await Future.delayed(...)`. |

## Keputusan teknis
- Simulasi tetap acak 30% di aplikasi sungguhan, tetapi sumber acaknya diinjeksi lewat provider agar perilaku bisa dibuktikan secara deterministik.
- Statistik dihitung dari state ToDo yang sama sehingga angka di `/stats` selalu cocok dengan daftar tugas; `build()` otomatis diulang saat daftar berubah.

## Hasil testing
`test/stats_test.dart` (7 test):
- Unit `StatsNotifier`: sukses sesuai daftar tugas, gagal -> `AsyncError`, batas 30% (0.3 dihitung sukses), retry setelah gagal lalu sukses, statistik diambil ulang saat daftar berubah.
- Widget `StatsPage`: loading -> success (ListView 3 item); error -> pesan + Coba lagi -> spinner -> success.

```text
> flutter analyze
No issues found!

> flutter test
+18: All tests passed!
```
Bukti: `screenshots/analyze_test.png`, tampilan: `screenshots/ai_stats_loading.png`, `ai_stats_error.png`, `ai_stats_success.png`.
