import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/core/failures.dart';
import 'package:week7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:week7_clean_architecture/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean_architecture/features/notes/domain/usecases/add_note.dart';

class RecordingRepository implements NoteRepository {
  String? savedTitle;
  String? savedBody;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: const <Note>[], failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    savedTitle = title;
    savedBody = body;
    return (
      note: Note(id: 1, title: title, body: body, updatedAt: DateTime(2026), dirty: true),
      failure: null,
    );
  }
}

void main() {
  test('AddNote menolak judul kosong tanpa menyentuh repository', () async {
    final repo = RecordingRepository();
    final result = await AddNote(repo).call(title: '   ');
    expect(result.failure, isA<ValidationFailure>());
    expect(repo.savedTitle, isNull);
  });

  test('AddNote merapikan input lalu menyimpan sebagai dirty', () async {
    final repo = RecordingRepository();
    final result = await AddNote(repo).call(title: '  Belanja ', body: ' susu ');
    expect(result.failure, isNull);
    expect(repo.savedTitle, 'Belanja');
    expect(repo.savedBody, 'susu');
    expect(result.note!.dirty, isTrue);
  });
}
