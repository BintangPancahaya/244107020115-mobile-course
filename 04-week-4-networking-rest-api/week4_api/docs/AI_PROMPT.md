# AI Challenge - Minggu 4

## Prompt yang digunakan
```
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```
AI yang dipakai: Claude (AI coding assistant).

## Output awal AI (ringkas)
- `Comment.fromJson` memakai pola `(json['id'] as num?)?.toInt() ?? 0`.
- `CommentRepository` membuat `Dio` dan timeout sendiri di dalam method.
- Fungsi pesan error baru khusus comment (duplikat dari `friendlyErrorMessage`).
- Satu unit test: field hilang.

## Hasil verifikasi (AI Verification Checklist)
| Cek | Hasil |
|---|---|
| UI memanggil Dio langsung? | Tidak. Halaman detail hanya memakai `commentsProvider`. |
| fromJson aman null? | Aman untuk field hilang, **tetapi crash** bila tipe salah (mis. `"id": "9"` -> `type 'String' is not a subtype of type 'num?'`). Ditemukan oleh edge case tambahan saya. |
| Semua DioExceptionType dipetakan? | Ya, lewat `friendlyErrorMessage` (timeout, connectionError, badResponse 404/500, default). |
| baseUrl/timeout terpusat? | Output awal tidak. Diperbaiki: repository menerima Dio dari `dioProvider` (`createDio()`). |
| Test hanya happy path? | Output awal hanya field hilang. Ditambah edge case tipe salah, mapping 404/500, dan timeout. |
| flutter analyze & flutter test | Lolos: No issues found, 9 test lulus. |

## Perbaikan yang dilakukan
1. `fromJson` diganti memakai helper `_toInt` (`v is num`) dan `_toStr` (`v is String`) sehingga tipe salah tidak crash.
2. Repository tidak membuat Dio sendiri; memakai `dioProvider` agar base URL, timeout 10 detik, dan logging tetap satu tempat.
3. Fungsi pesan error duplikat dihapus; memakai ulang `lib/data/network_errors.dart`.
4. `retry: (retryCount, error) => null` ditambahkan pada provider agar error langsung final (Riverpod 3).

## Alasan keputusan teknis
Konfigurasi jaringan terpusat memudahkan perubahan base URL/timeout dan pengujian dengan repository palsu. Validasi tipe di `fromJson` melindungi aplikasi dari respons API yang tidak sesuai dokumentasi.
