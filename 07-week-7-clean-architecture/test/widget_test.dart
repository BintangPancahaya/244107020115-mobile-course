import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:week7_clean_architecture/features/notes/presentation/widgets/note_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('NoteTile menampilkan badge bila dirty', (tester) async {
    await tester.pumpWidget(_wrap(NoteTile(
      note: Note(title: 'Belanja', updatedAt: DateTime(2026, 9, 18), dirty: true),
    )));
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('belum tersinkron'), findsOneWidget);
  });
}
