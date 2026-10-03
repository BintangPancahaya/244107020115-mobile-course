# Minggu 6 - Authentication, Security & FCM

**Nama:** Bintang Pancahaya P
**NIM:** 244107020115
**Kelas:** TI-3F
**Mata Kuliah:** Pemrograman Mobile - Politeknik Negeri Malang

## Tujuan
Membangun **Campus Notification App**: login (mock auth yang siap diganti Firebase Auth) dengan guard route, token di secure storage, Dio yang otomatis refresh sekali saat 401, serta integrasi FCM (permission, token lifecycle, topik, tiga app state, deep link `/pengumuman/:id`).

## Fitur utama
- **Praktikum 1:** `TokenStore` (flutter_secure_storage), `AuthRepository` mock, `buildApiClient` (interceptor Bearer + refresh sekali saat 401 lalu retry; refresh gagal -> `clear()`), `AuthNotifier` + guard GoRouter (`authRedirect`).
- **Praktikum 2:** `push_service.dart`: `requestNotificationPermission`, `initLocalNotifications`, `initFcmToken` (getToken + `onTokenRefresh` -> `POST /devices` + subscribe `pengumuman-kampus`). Kartu debug menampilkan token **terpotong** (12 karakter).
- **Praktikum 3:** background handler top-level `@pragma('vm:entry-point')`, `listenForeground` (local notification manual + `onMessageOpenedApp`), `handleTerminated` (`getInitialMessage`), payload gabungan `notification` + `data.route`.
- **Refactoring:** semua rute di `lib/routes.dart`, `routeFromMessage` sebagai fungsi murni, pemetaan error di `lib/data/api_errors.dart`.

## Stack
Flutter 3.47, Dart 3.13, `flutter_riverpod` 3, `go_router`, `dio`, `flutter_secure_storage` 11, `firebase_core`, `firebase_messaging` 17, `flutter_local_notifications` 22.

## Cara menjalankan
```
flutter pub get
flutter run        # pilih [2] Chrome
flutter analyze
flutter test
```
Login: email apa pun yang mengandung `@` dan kata sandi minimal 6 karakter (mock).

### Mengaktifkan FCM sungguhan
Project Firebase harus dibuat dengan akun Google pemilik project (tidak dibuat di sesi ini):
1. Buat project di Firebase Console, tambahkan aplikasi Android (`applicationId` di `android/app/build.gradle.kts`).
2. Jalankan `dart pub global activate flutterfire_cli` lalu `flutterfire configure` (menghasilkan `firebase_options.dart` + `google-services.json`).
3. Ubah `Firebase.initializeApp()` menjadi `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
4. Jalankan di perangkat Android dengan Google Play Services, lalu kirim kampanye uji dari Firebase Console (bukti `fcm-console-test.png`).

Tanpa konfigurasi itu, `initPush` mendeteksi `Firebase.apps.isEmpty` dan aplikasi tetap berjalan; kartu debug menampilkan status "Firebase belum dikonfigurasi".

## Hasil praktikum (folder `screenshot/`)
| File | Keterangan |
|---|---|
| `praktikum1_login.png` | Halaman login (guard: belum login diarahkan ke `/login`) |
| `praktikum2_beranda.png` | Beranda setelah login: kartu debug (access token terpotong, secure storage, topik, status FCM) + 3 pengumuman |
| `praktikum3_detail.png` | Halaman tujuan deep link `/pengumuman/3` dari payload `data.route` |
| `flutter_test.png` | Hasil `flutter test`: 13 test lulus |

Catatan screenshot: Chrome tidak bisa diklik karena komputer dikendalikan dari jarak jauh. Kondisi tiap screenshot disiapkan `lib/screenshot_main.dart`: login memakai `AuthRepository` + `TokenStore` asli, dan scene detail memproses payload `{'route': '/pengumuman/3', 'id': '3'}` lewat `routeFromMessage` (fungsi yang sama dengan handler klik notifikasi), lalu menjalankan `CampusApp` yang sama dengan `main.dart`.

## Matriks pengujian tiga app state
| State | Yang diharapkan | Cara uji | Status |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari console/backend | Logika `routeFromMessage` + `payload: route` teruji unit; uji perangkat menunggu konfigurasi Firebase |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik banner | `onMessageOpenedApp` -> `go(routeFromMessage(data))`; uji perangkat menunggu Firebase |
| Terminated | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik banner | `handleTerminated` dipanggil setelah router siap; uji perangkat menunggu Firebase |

Detail langkah ada di `docs/matriks-uji.md`.

## Testing
- `flutter analyze`: No issues found. Dua pemakaian API deprecated (`getToken`, `onTokenRefresh` di firebase_messaging 17) dipertahankan sesuai modul dan diberi komentar.
- `flutter test`: 13 test lulus - `auth_push_test.dart` (4 test dari modul), `session_test.dart` (8 test terhadap kode asli: routeFromMessage, authRedirect, shortToken, friendlyApiError, login sukses/gagal, logout, refresh kosong), `widget_test.dart` (form login).
- Catatan: import `flutter_riverpod` yang tidak terpakai pada contoh `auth_push_test.dart` di modul dihapus agar analyze bersih.

## Refleksi
- **Refresh token di SharedPreferences?** Tidak boleh: SharedPreferences tidak terenkripsi (plain XML/localStorage), mudah dibaca di perangkat root/backup. Bila bocor, penyerang bisa terus mencetak access token baru tanpa kata sandi sampai refresh token dicabut.
- **Mengabaikan `onTokenRefresh`:** setelah reinstall/clear data/rotasi, backend menyimpan token basi sehingga notifikasi pengumuman tidak sampai ke mahasiswa sepanjang semester tanpa ada error yang terlihat.
- **Topik vs token:** topik untuk broadcast (mis. "Kuliah libur 17 Agustus" ke `pengumuman-kampus`), token perangkat untuk pesan personal (mis. "Nilai UTS Pemrograman Mobile sudah keluar", tagihan UKT).
- **Draf AI yang diperbaiki:** lihat `docs/AI_PROMPT.md`.
