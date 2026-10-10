import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/core/format.dart';

void main() {
  test('formatDateTime dd/MM/yyyy HH:mm', () {
    expect(formatDateTime(DateTime(2026, 9, 5, 7, 3)), '05/09/2026 07:03');
    expect(formatDateTimeOrDash(null), '-');
  });

  test('parseNoteId dan noteRoute', () {
    expect(noteRoute(3), '/note/3');
    expect(parseNoteId('12'), 12);
    expect(parseNoteId('abc'), isNull);
    expect(parseNoteId(null), isNull);
  });
}
