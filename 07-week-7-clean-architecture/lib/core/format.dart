// Fungsi murni (tanpa Flutter) untuk formatting tanggal dan parsing rute,
// sehingga bisa diuji tanpa widget.

String _two(int v) => v.toString().padLeft(2, '0');

/// dd/MM/yyyy HH:mm
String formatDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

String formatDateTimeOrDash(DateTime? d) => d == null ? '-' : formatDateTime(d);

/// Rute detail catatan: /note/:id
String noteRoute(int id) => '/note/$id';

/// Parsing aman parameter :id dari rute. Null bila bukan angka.
int? parseNoteId(String? raw) => int.tryParse(raw ?? '');
