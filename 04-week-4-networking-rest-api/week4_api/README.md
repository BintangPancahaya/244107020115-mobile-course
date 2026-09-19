# Minggu 4 - Networking & REST API

**Nama:** Bintang Pancahaya P
**NIM:** 244107020115
**Kelas:** TI-3F
**Mata Kuliah:** Pemrograman Mobile - Politeknik Negeri Malang

## Tujuan
Mengambil data dari REST API (JSONPlaceholder) dengan repository layer, model `fromJson` aman null, Dio terpusat, Riverpod, serta menampilkan state loading, error (+ retry), empty, dan success. Ditambah pagination infinite scroll.

## Fitur utama
- Dio terpusat (`lib/data/api_client.dart`): base URL, timeout 10 detik, `LogInterceptor`.
- Model `Post` dan `Comment` dengan `fromJson` aman null.
- `PostRepository` (`fetchPosts`, `fetchPostsPage`, `fetchPost`) dan `CommentRepository` (`fetchComments`).
- `AsyncNotifierProvider` + pesan error ramah pengguna (`lib/data/network_errors.dart`).
- Halaman list (4 state), halaman paged (infinite scroll 10 item/halaman, guard request ganda), halaman detail `/post/:id` (GoRouter) beserta komentar.
- Refactoring: widget `PostTile`, `friendlyErrorMessage` dipindah ke `network_errors.dart`, detail post via GoRouter.

## Stack
Flutter 3.47, Dart 3.13, `dio`, `flutter_riverpod` 3, `go_router`.

## Cara menjalankan
```
flutter pub get
flutter run            # pilih [2] Chrome
flutter run --dart-define=START=/post/1   # langsung membuka detail post 1
flutter analyze
flutter test
```

## Hasil praktikum (folder `screenshot/`)
| File | Keterangan |
|---|---|
| `praktikum1_posts.png` | Praktikum 1-2: daftar 100 posts (success state) |
| `praktikum2_baseurl.png` | Praktikum 2: baseUrl sengaja diubah ke URL salah -> pesan error ramah + tombol Coba lagi |
| `praktikum2_offline.png` | Praktikum 2: simulasi offline -> pesan "Tidak dapat terhubung ke server" |
| `praktikum3_paged.png` | Praktikum 3: halaman paged, halaman 1 tampil + indikator loading di bawah |
| `refactor_detail_post.png` | Refactoring: halaman detail `/post/1` (GoRouter) + komentar (AI Challenge) |

Catatan uji offline: karena komputer dikendalikan jarak jauh, internet tidak bisa benar-benar dimatikan. Kondisi offline disimulasikan dengan menjalankan Chrome lewat proxy yang tidak bisa dijangkau untuk host API (`flutter run --web-browser-flag=--proxy-server=127.0.0.1:9 "--web-browser-flag=--proxy-bypass-list=*.gstatic.com;*.googleapis.com"`), sehingga request ke JSONPlaceholder gagal dengan `DioExceptionType.connectionError` seperti saat mode pesawat.

## Testing
`flutter analyze`: No issues found. `flutter test`: 9 test lulus (`post_test.dart` 4 test, `comment_test.dart` 4 test, `widget_test.dart` 1 test). Semua test memakai repository palsu / data lokal, tanpa HTTP sungguhan.

## Refleksi singkat
- UI dilarang memanggil Dio langsung agar logika jaringan, error mapping, dan testing terpusat di repository/provider; jika dilanggar, UI sulit diuji dan konfigurasi tersebar.
- Pagination client-side cukup untuk data kecil; data besar harus memakai pagination server (`_page`/`_limit`) agar hemat bandwidth dan memori.
- Exception repository yang dilempar di `build()` otomatis menjadi `AsyncError`; try/catch eksplisit tetap dibutuhkan saat mengubah state manual (mis. `refresh()` dan `loadNextPage()` yang mempertahankan data lama).
- Hasil AI yang diperbaiki dijelaskan di `docs/AI_PROMPT.md`.
