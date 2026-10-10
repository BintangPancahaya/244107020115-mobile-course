import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/database/db.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';

// Data layer: database opener disuntikkan (mudah diganti fake saat test).
// Satu instance implementasi dipakai untuk tiga kontrak (ISP).
final _noteRepositoryImplProvider = Provider<NoteRepositoryImpl>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final noteRepositoryProvider = Provider<NoteRepository>(
    (ref) => ref.watch(_noteRepositoryImplProvider));
final noteEditRepositoryProvider = Provider<NoteEditRepository>(
    (ref) => ref.watch(_noteRepositoryImplProvider));
final noteSyncRepositoryProvider = Provider<NoteSyncRepository>(
    (ref) => ref.watch(_noteRepositoryImplProvider));

// Domain layer: use case menerima abstraksi, bukan implementasi.
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});
final addNoteProvider =
    Provider<AddNote>((ref) => AddNote(ref.watch(noteRepositoryProvider)));
final syncNotesProvider = Provider<SyncNotes>(
    (ref) => SyncNotes(ref.watch(noteSyncRepositoryProvider)));

// Presentation layer: state untuk UI. Failure dilempar apa adanya agar UI
// hanya membaca failure.message (bukan exception mentah).
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) throw result.failure!;
  return result.notes;
}, retry: (retryCount, error) => null);

final dirtyCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(notesProvider.future);
  final result = await ref.read(noteSyncRepositoryProvider).countDirty();
  if (result.failure != null) throw result.failure!;
  return result.count;
}, retry: (retryCount, error) => null);

/// Detail dibaca langsung dari repository lokal (CRUD satu baris: tanpa use case).
final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) async {
  ref.watch(notesProvider);
  final result = await ref.read(noteEditRepositoryProvider).fetchNote(id);
  if (result.failure != null) throw result.failure!;
  return result.note;
}, retry: (retryCount, error) => null);
