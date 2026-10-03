# Matriks Uji Tiga App State

Payload yang dipakai (FCM HTTP v1):
```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": { "route": "/pengumuman/3", "id": "3" }
  }
}
```

| State | Handler | Yang diharapkan | Cara uji di perangkat |
|---|---|---|---|
| Foreground | `FirebaseMessaging.onMessage` -> `_local.show(payload: route)`; klik -> `pendingDeepLink` | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari Firebase Console |
| Background | Banner sistem otomatis; `onMessageOpenedApp` -> `go(routeFromMessage(data))` | Klik banner membuka `/pengumuman/3` | Tekan Home, kirim, klik banner |
| Terminated | `getInitialMessage()` di `handleTerminated` setelah router siap | Aplikasi terbuka langsung ke `/pengumuman/3` | Swipe-close aplikasi, kirim, klik banner |

Bukti yang sudah ada tanpa Firebase:
- `routeFromMessage` teruji unit untuk payload kosong, tanpa slash, dan tipe salah.
- `screenshot/praktikum3_detail.png`: payload di atas diproses `routeFromMessage` dan membuka `/pengumuman/3`.

Bukti yang menunggu project Firebase (lihat README "Mengaktifkan FCM sungguhan"): banner per state dan `fcm-console-test.png`.
