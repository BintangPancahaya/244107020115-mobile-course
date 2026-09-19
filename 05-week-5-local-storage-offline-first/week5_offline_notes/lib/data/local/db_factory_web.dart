import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web (Chrome): SQLite WASM lewat sqflite_common_ffi_web.
void configureDbFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
