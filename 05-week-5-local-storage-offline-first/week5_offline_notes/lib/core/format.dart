String _two(int v) => v.toString().padLeft(2, '0');

/// Format sederhana dd/MM/yyyy HH:mm tanpa package intl.
String formatDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
