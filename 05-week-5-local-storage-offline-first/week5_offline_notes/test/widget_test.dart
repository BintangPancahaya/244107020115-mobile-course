import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('NoteTile menampilkan badge bila dirty', (tester) async {
    await tester.pumpWidget(_wrap(NoteTile(
      note: Note(title: 'Belanja', updatedAt: DateTime(2026, 9, 18), dirty: true),
    )));
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('belum tersinkron'), findsOneWidget);
  });

  testWidgets('NoteTile tanpa badge bila sudah sinkron', (tester) async {
    await tester.pumpWidget(_wrap(NoteTile(
      note: Note(title: 'Rapi', updatedAt: DateTime(2026, 9, 18)),
    )));
    expect(find.text('belum tersinkron'), findsNothing);
  });
}
