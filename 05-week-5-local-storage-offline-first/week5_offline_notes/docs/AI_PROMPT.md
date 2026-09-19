# AI Challenge - Minggu 5

## Prompt
```
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```
AI yang dipakai: Claude (AI coding assistant).

## Output awal AI (ringkas)
| Kriteria | SharedPreferences | Hive | sqflite | Drift |
|---|---|---|---|---|
| Kompleksitas query | Tidak ada (key-value) | Terbatas (filter di Dart) | SQL penuh | SQL penuh, type-safe |
| Relasi | Tidak | Manual | Ya (JOIN, FK) | Ya |
| Reaktivitas (stream) | Tidak | `box.watch()` | Tidak bawaan | `watch()` query |
| Type-safety | Rendah | Sedang (adapter) | Rendah (Map) | Tinggi (codegen) |
| Boilerplate | Sangat kecil | Kecil + adapter | Sedang (SQL manual) | Besar (codegen, build_runner) |
| Testing | Mudah (mock values) | Sedang | Mudah via injeksi openDb / ffi | Mudah (in-memory) |

Rekomendasi awal AI: **Drift** untuk catatan (reaktif, type-safe), **SharedPreferences** untuk tema.

Skema usulan AI untuk 1000+ catatan:
```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

## Verifikasi (AI Verification Checklist)
| Cek | Temuan |
|---|---|
| Catatan ditaruh di SharedPreferences? | Tidak. AI menempatkan SharedPreferences hanya untuk tema - sesuai. |
| Skema mendukung antrean sync? | Ya, ada `dirty` dan `updated_at` + index `dirty` agar `countDirty()` tetap cepat untuk 1000+ baris. |
| Klaim "real-time" didukung stream? | Hanya benar untuk Drift (`watch`) dan Hive (`box.watch`). Untuk sqflite, "real-time" di aplikasi ini dicapai dengan `ref.invalidate(notesProvider)` setelah mutasi, bukan stream. |
| Estimasi boilerplate masuk akal? | Untuk Drift terlalu optimistis: butuh `drift`, `drift_dev`, `build_runner`, codegen, dan di Web butuh setup WASM + worker. sqflite cukup `flutter pub add` + SQL manual; di Web cukup `sqflite_common_ffi_web:setup`. |

## Keputusan final
| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Preferensi tema & waktu dibuka | **SharedPreferences** | Data kecil key-value, API sederhana, didukung semua platform termasuk Web. |
| Catatan (CRUD, urut `updated_at`, antrean sync) | **sqflite (SQLite)** | Query SQL + index cukup untuk 1000+ catatan, tanpa codegen; repository dengan injeksi `openDb` mudah diuji dengan `FakeNoteRepository`. |

Rekomendasi AI yang **ditolak**: Drift untuk catatan. Alasannya kebutuhan stream belum ada (cukup invalidasi provider), boilerplate codegen lebih besar, dan modul mewajibkan sqflite. Drift dipertimbangkan bila nanti butuh UI reaktif lintas layar.

## Hasil testing
`flutter analyze` - No issues found. `flutter test` - 6 test lulus (lihat `screenshot/flutter_test.png`).
