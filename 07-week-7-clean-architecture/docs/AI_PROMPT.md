# AI Challenge - Minggu 7

## Prompt
Prompt modul ditujukan untuk `campus_notify`; karena project yang direfactor adalah Offline Notes (Minggu 5), konteksnya disesuaikan:
```
Project Flutter saya: week5_offline_notes (catatan SQLite + preferensi + posts cache-first).
Kondisi kini: folder lib/{data, pages, widgets, core},
repository tercampur dengan implementasi, provider dibuat di file halaman.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur notes + settings (+ posts).
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```
AI yang dipakai: Claude (AI coding assistant).

## Output awal AI (ringkas)
- Struktur `features/{notes,settings,posts}/{domain,data,presentation}` + `core/`.
- Use case untuk **setiap** operasi: `GetNotes`, `AddNote`, `DeleteNote`, `GetNoteById`, `CountDirty`, `MarkAllSynced`, `SyncNotes`, `GetDarkMode`, `SetDarkMode`, `ToggleDarkMode`, `GetLastOpened`, `MarkOpened`, `GetCachedPosts`, `RefreshPosts`.
- Satu interface `NoteRepository` berisi 7 method.
- `core/database/db.dart` (mengimpor sqflite) dan `core/connectivity_provider.dart` (mengimpor Riverpod).
- Package `get_it` disarankan sebagai alternatif DI.

## Tabel usulan vs keputusan final
| Usulan AI | Keputusan final | Alasan |
|---|---|---|
| Use case untuk tiap operasi (14 kelas) | Hanya 4: `GetNotes` (modul), `AddNote`, `SyncNotes`, `ToggleDarkMode` | Hanya operasi dengan aturan bisnis yang diberi use case. `fetchNote`, `deleteNote`, cache posts = CRUD satu baris -> repository langsung ke provider (over-engineering ditolak). |
| Satu interface `NoteRepository` gemuk (7 method) | Dipecah: `NoteRepository` (fetch/add, sesuai modul), `NoteEditRepository`, `NoteSyncRepository` | Interface Segregation; `FakeNoteRepository` di test modul tetap cukup mengimplementasikan 2 method. Satu `NoteRepositoryImpl` mengimplementasikan ketiganya. |
| `core/database/db.dart` (import sqflite) | Dipindah ke `shared/database/` | Grep #2 mewajibkan `lib/core` bebas sqflite. |
| `core/connectivity_provider.dart` (import Riverpod) | Dipindah ke `shared/connectivity.dart` | Pola `import 'package:flutter` pada grep #2 juga menangkap `flutter_riverpod`; core harus murni Dart. |
| Interface di domain, impl di data | Diterima | Sesuai dependency rule. |
| Entity tanpa mapping, `toMap/fromMap/toJson` di model | Diterima (`NoteModel`, `PostModel`) | Mapping hanya di data layer. |
| `get_it` | Ditolak | Modul meminta DI dengan Riverpod saja; provider sudah memberi override untuk test. |
| `Dio(BaseOptions(...))` di provider posts | Dipindah ke `data/remote/http_client.dart` (`buildPostsHttpClient`) | Presentation harus nol hasil untuk `Dio(`. |
| Provider melempar `Exception(failure.message)` | Melempar `Failure` apa adanya + `messageOf()` | Refactoring challenge: UI hanya menerima `message`, bukan string "Exception: ...". |

## Hasil tiga grep verifikasi
Lihat `docs/verifikasi-grep.txt`: ketiganya 0 hasil, `flutter analyze` bersih, 11 test lulus.
