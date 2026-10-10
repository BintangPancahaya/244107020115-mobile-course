# Keputusan Final Arsitektur

1. **Feature-first**: `notes`, `settings`, `posts`, masing-masing `domain/data/presentation`. Tidak ada fitur yang tertinggal "kotor".
2. **Domain murni**: entity, interface repository, use case, dan `Failure` (sealed) tanpa import Flutter/Dio/SQLite/Firebase.
3. **Kontrak hasil** memakai record Dart `({T value, Failure? failure})`; exception teknis berhenti di data layer.
4. **Use case hanya bila ada aturan bisnis**: `GetNotes`, `AddNote` (validasi + trim), `SyncNotes` (offline -> tunda, upload, tandai bersih, last-write-wins `updated_at`), `ToggleDarkMode`.
5. **DI terpusat** di `presentation/providers/*_providers.dart`; widget tidak pernah membuat repository.
6. **Infrastruktur bersama** (`shared/database`, `shared/connectivity.dart`) dipisah dari `core` agar core tetap murni.
7. **Perilaku identik** dibuktikan dengan screenshot before/after pada skenario yang sama.
