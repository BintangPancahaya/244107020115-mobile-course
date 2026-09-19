# Aturan Konflik Sinkronisasi

**Aturan: last-write-wins berdasarkan `updated_at`.**

1. Setiap tulis lokal (tambah/ubah) mengisi `updated_at = DateTime.now()` dan `dirty = 1`.
2. Saat sync, catatan dirty dikirim ke server beserta `updated_at`.
3. Bila server memiliki versi catatan yang sama:
   - `updated_at` lokal lebih baru -> versi lokal menimpa server.
   - `updated_at` server lebih baru -> versi server menimpa lokal (catatan lokal ditandai bersih).
4. `markAllSynced()` hanya dipanggil setelah server menjawab sukses (2xx). Bila gagal/offline, `dirty` tetap 1 sehingga badge tetap akurat dan catatan akan dicoba lagi.

Konsekuensi: perubahan yang lebih lama pada perangkat lain bisa hilang. Ini diterima untuk catatan pribadi. Untuk data kolaboratif diperlukan versi/merge per field.

## Observasi offline
1. Paksa offline (toggle `forceOffline`), tambah 2 catatan -> badge "2 belum tersinkron" (`screenshot/praktikum3_dirty_sebelum.png`). Catatan tetap tersimpan dan tampil karena dibaca dari SQLite lokal.
2. Online kembali, jalankan `syncNotes` -> badge "Sinkron" dan SnackBar "2 catatan berhasil disinkronkan" (`screenshot/praktikum3_dirty_sesudah.png`).
