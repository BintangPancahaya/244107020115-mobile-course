import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/features/notes/data/models/note_model.dart';
import 'package:week7_clean_architecture/features/notes/domain/entities/note.dart';

void main() {
  test('NoteModel.fromMap aman terhadap field yang hilang', () {
    final m = NoteModel.fromMap({'title': 'Belanja'});
    expect(m.title, 'Belanja');
    expect(m.body, '');
    expect(m.dirty, isFalse);
  });

  test('toMap -> fromMap -> toEntity mempertahankan dirty', () {
    final model = NoteModel(title: 'a', updatedAt: DateTime(2026, 9, 18), dirty: true);
    final entity = NoteModel.fromMap(model.toMap()).toEntity();
    expect(entity, isA<Note>());
    expect(entity, isNot(isA<NoteModel>()));
    expect(entity.dirty, isTrue);
  });
}
