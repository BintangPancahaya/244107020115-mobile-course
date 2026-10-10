import '../../domain/entities/note.dart';
import '../../../../core/failures.dart';

abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });
}

/// Interface Segregation: operasi detail/hapus dipisah dari kontrak utama,
/// sehingga fake di test cukup mengimplementasikan yang dibutuhkan.
abstract class NoteEditRepository {
  Future<({Note? note, Failure? failure})> fetchNote(int id);
  Future<Failure?> deleteNote(int id);
}

/// Kontrak antrean sync (dirty flag).
abstract class NoteSyncRepository {
  Future<({int count, Failure? failure})> countDirty();
  Future<Failure?> markAllSynced();
}
