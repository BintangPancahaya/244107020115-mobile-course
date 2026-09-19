import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/format.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../widgets/note_tile.dart';

/// Detail dibaca dari repository lokal (SQLite), bukan dari state list.
final noteByIdProvider = FutureProvider.family<Note?, int>(
  (ref, id) {
    ref.watch(notesProvider); // segarkan bila daftar berubah
    return ref.read(noteRepositoryProvider).fetchNote(id);
  },
  retry: (retryCount, error) => null,
);

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal membaca catatan: $err')),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(note.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Diubah ${formatDateTime(note.updatedAt)}'),
                  if (note.dirty) const DirtyBadge(),
                ],
              ),
              const Divider(height: 32),
              Text(note.body.isEmpty ? '(tanpa isi)' : note.body,
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          );
        },
      ),
    );
  }
}
