import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case karena punya aturan bisnis: judul wajib diisi, maksimal
/// 100 karakter, dan input dirapikan (trim) sebelum disimpan.
class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      return (note: null, failure: const ValidationFailure('Judul catatan wajib diisi.'));
    }
    if (cleanTitle.length > 100) {
      return (note: null, failure: const ValidationFailure('Judul maksimal 100 karakter.'));
    }
    return _repository.addNote(title: cleanTitle, body: body.trim());
  }
}
