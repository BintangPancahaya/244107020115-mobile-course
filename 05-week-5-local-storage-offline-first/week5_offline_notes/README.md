# Minggu 5 - Local Storage & Offline First

**Nama:** Bintang Pancahaya P
**NIM:** 244107020115
**Kelas:** TI-3F
**Mata Kuliah:** Pemrograman Mobile - Politeknik Negeri Malang

## Tujuan
Membangun aplikasi **Offline Notes**: preferensi via SharedPreferences, CRUD catatan persisten via SQLite (sqflite) lewat repository + Riverpod, serta pola offline-first (cache-first untuk bacaan, dirty flag + `syncNotes` untuk tulisan).

## Fitur utama
- **Praktikum 1 - SharedPreferences:** `PrefsRepository` (tema gelap + waktu terakhir dibuka), `DarkModeNotifier`, halaman Pengaturan.
- **Praktikum 2 - SQLite:** model `Note` (flag `dirty`), `openNotesDb()`, `NoteRepository` (fetch/add/delete/countDirty/markAllSynced), halaman catatan dengan badge antrean sync. Daftar diurutkan `updated_at` terbaru.
- **Praktikum 3 - Offline-first:** tab Posts cache-first (tabel `cached_posts`, refresh di background), `syncNotes`, toggle `forceOffline` deterministik.
- **Refactoring:** widget `NoteTile` dengan badge "belum tersinkron", logika cache + sync dipindah ke `lib/data/sync.dart`, halaman detail `/note/:id` (GoRouter) yang membaca langsung dari repository lokal.
- **Aturan konflik:** last-write-wins berdasarkan `updated_at` (lihat `docs/aturan-konflik.md`).

## Stack
Flutter 3.47, Dart 3.13, `flutter_riverpod` 3, `shared_preferences`, `sqflite`, `path`, `dio`, `go_router`, `sqflite_common_ffi_web`.

> `sqflite` tidak punya implementasi Web. Agar aplikasi bisa dijalankan di Chrome dengan **SQLite sungguhan**, factory database diganti ke `sqflite_common_ffi_web` (SQLite WASM + IndexedDB) lewat conditional import (`lib/data/local/db_factory*.dart`). Di Android/iOS tetap memakai sqflite bawaan; kode repository tidak berubah.

## Cara menjalankan
```
flutter pub get
dart run sqflite_common_ffi_web:setup   # sekali, menyalin sqlite3.wasm + sqflite_sw.js ke web/
flutter run                              # pilih [2] Chrome
flutter analyze
flutter test
```

## Hasil praktikum (folder `screenshot/`)
| File | Keterangan |
|---|---|
| `praktikum1_pengaturan_terang.png` | Pengaturan: tema terang, waktu terakhir dibuka, toggle paksa offline |
| `praktikum1_pengaturan_gelap.png` | Pengaturan: tema gelap aktif (tersimpan di SharedPreferences) |
| `praktikum2_daftar_catatan.png` | Daftar catatan dari SQLite + badge "belum tersinkron" |
| `praktikum2_dialog_tambah.png` | Dialog tambah catatan |
| `praktikum3_dirty_sebelum.png` | Mode offline: 2 catatan dirty, badge "2 belum tersinkron" |
| `praktikum3_dirty_sesudah.png` | Setelah `syncNotes`: badge "Sinkron" + SnackBar "2 catatan berhasil disinkronkan" |
| `flutter_test.png` | Hasil `flutter test`: 6 test lulus |

Catatan pengambilan screenshot: komputer dikendalikan dari jarak jauh, sehingga Chrome tidak bisa diklik. Karena itu kondisi tiap screenshot disiapkan oleh `lib/screenshot_main.dart` (`flutter run -t lib/screenshot_main.dart --dart-define=SCENE=...`). Entrypoint ini memanggil repository/provider **asli** (SQLite WASM + SharedPreferences sungguhan) dan fungsi UI yang sama dengan tombol aplikasi (`showAddNoteDialog`, `syncNow`), lalu menjalankan `MyApp` yang sama dengan `main.dart`. Mode offline memakai toggle `forceOffline` sesuai saran modul (simulasi offline deterministik).

## Testing
- `flutter analyze`: No issues found.
- `flutter test`: 6 test lulus - `note_test.dart` (fromMap aman null, flag dirty, provider sukses & error dengan `FakeNoteRepository`) dan `widget_test.dart` (NoteTile dengan/tanpa badge). Tidak ada test yang menyentuh SQLite sungguhan.

## Refleksi
- **Mengapa catatan tidak di SharedPreferences?** SharedPreferences hanya key-value untuk data kecil; koleksi harus diserialisasi utuh setiap perubahan, tidak bisa query/urut/filter, rawan rusak saat tulis bersamaan, dan lambat saat data membesar.
- **Cache-first vs strategi lain:** cache-first cocok untuk data bacaan yang boleh sedikit basi (artikel, daftar post). Data real-time seperti harga saham atau saldo butuh network-first dengan fallback cache + penanda "data lama".
- **Dirty flag sebagai antrean:** tulisan langsung ke SQLite dengan `dirty = 1` (UI tidak menunggu jaringan); sync berjalan terpisah lalu `markAllSynced` setelah server sukses. Tabel outbox terpisah diperlukan bila ada operasi hapus/ubah berurutan yang harus direplay sesuai urutan, retry per item, atau banyak perangkat.
- **Rekomendasi AI yang ditolak:** lihat `docs/AI_PROMPT.md`.
