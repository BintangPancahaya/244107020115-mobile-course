import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/format.dart';
import '../../../../shared/connectivity.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_actions.dart';
import '../widgets/note_tile.dart';

/// Halaman hanya membaca state: tanpa SQL, Dio, JSON, atau formatting mentah.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          if (offline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(Icons.cloud_off, size: 16),
                label: Text('Offline'),
              ),
            ),
          Chip(
            avatar: Icon(dirty == 0 ? Icons.cloud_done : Icons.cloud_upload,
                size: 16),
            label: Text(dirty == 0 ? 'Sinkron' : '$dirty belum tersinkron'),
          ),
          IconButton(
            tooltip: 'Sinkronkan',
            icon: Badge(
              isLabelVisible: dirty > 0,
              label: Text('$dirty'),
              child: const Icon(Icons.sync),
            ),
            onPressed: () => syncNow(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah catatan',
        onPressed: () => showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(notesProvider),
        ),
        data: (notes) => notes.isEmpty
            ? const Center(
                child: Text('Belum ada catatan. Tekan + untuk menambah.'))
            : ListView.separated(
                itemCount: notes.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteTile(
                    note: note,
                    onTap: note.id == null
                        ? null
                        : () => context.push(noteRoute(note.id!)),
                    onDelete: note.id == null
                        ? null
                        : () => deleteNote(context, note.id!),
                  );
                },
              ),
      ),
    );
  }
}
