// sqflite tidak punya implementasi Web. Saat dijalankan di Chrome,
// factory diganti ke sqflite_common_ffi_web (SQLite WASM + IndexedDB),
// sehingga kode repository yang sama tetap memakai SQLite sungguhan.
export 'db_factory_stub.dart'
    if (dart.library.js_interop) 'db_factory_web.dart';
