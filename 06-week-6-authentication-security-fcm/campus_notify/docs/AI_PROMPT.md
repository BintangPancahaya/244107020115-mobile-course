# AI Challenge - Minggu 6

## Prompt
```
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```
AI yang dipakai: Claude (AI coding assistant).

## Output awal AI (ringkas)
- `class PushService` dengan method `init(BuildContext context)` yang memanggil `context.go(...)` di dalam listener.
- Background handler ditulis sebagai `static Future<void> _onBackground(...)` di dalam kelas.
- `onTokenRefresh.listen((t) => debugPrint('FCM token: $t'))`.
- `flutter_local_notifications` dipanggil dengan API lama (`initialize(settings)` posisional, `show(id, title, body, details)`).
- Catatan platform: Android 13+ butuh `POST_NOTIFICATIONS` runtime permission; iOS butuh APNs key + capability Push.

## Verifikasi (AI Verification Checklist)
| Cek | Temuan | Tindakan |
|---|---|---|
| Background handler top-level + `@pragma('vm:entry-point')`? | Tidak, berupa static method kelas. | Diganti fungsi top-level `firebaseMessagingBackgroundHandler` dengan `@pragma('vm:entry-point')`. |
| `onTokenRefresh` mengirim ke backend? | Tidak, hanya `debugPrint` (dan mencetak token penuh). | Diganti `onToken` -> `POST /devices` lewat `apiClientProvider`. |
| Foreground memakai local notification manual? | Ya. | Dipertahankan, payload diisi `routeFromMessage(message.data)`. |
| Klik dari 3 state masuk rute benar? | Navigasi lewat `BuildContext` yang bisa sudah tidak valid saat terminated. | Navigasi lewat callback `go` ke `routerProvider` (tanpa BuildContext); `handleTerminated` dipanggil setelah router siap. Tabel uji di README. |
| Token/secret tidak di-hardcode/di-log penuh? | Token di-log penuh. | Log dihapus; tampilan hanya `shortToken` (12 karakter). Token sesi di `flutter_secure_storage`. |
| API plugin sesuai versi? | API `flutter_local_notifications` lama tidak kompilasi di v22. | Disesuaikan ke parameter bernama (`settings:`, `id:`, `notificationDetails:`). |

## Keputusan final
- Pakai fungsi-fungsi top-level di `push_service.dart` (sesuai modul) + `initPush` sebagai orkestrator, bukan kelas yang menyimpan `BuildContext`.
- `initPush` memeriksa `Firebase.apps.isEmpty` agar aplikasi tetap jalan saat Firebase belum dikonfigurasi (mis. Web/CI).
- `getToken`/`onTokenRefresh` tetap dipakai sesuai modul walau deprecated di firebase_messaging 17; migrasi ke `register()/onRegistered` dicatat sebagai pekerjaan lanjutan.

## Daftar perbaikan manual
1. Background handler -> top-level + pragma.
2. `onTokenRefresh` -> kirim ke `POST /devices`, tanpa log token.
3. Navigasi deep link tanpa `BuildContext` (callback `go`).
4. Parsing payload diekstrak ke `routeFromMessage` (diuji unit, termasuk `route` bukan String).
5. Penyesuaian API `flutter_local_notifications` v22.
