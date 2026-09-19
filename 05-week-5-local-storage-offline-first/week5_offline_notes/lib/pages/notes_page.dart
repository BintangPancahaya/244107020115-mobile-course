import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';

/// Halaman catatan offline. Semua data dari SQLite lokal lewat
/// repository + provider, jadi tetap berfungsi penuh dalam mode pesawat.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
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
            avatar: Icon(
                dirty == 0 ? Icons.cloud_done : Icons.cloud_upload,
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
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gagal membaca database lokal: $err',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(notesProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
                child: Text('Belum ada catatan. Tekan + untuk menambah.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = items[index];
              return NoteTile(
                note: note,
                onTap: () => context.push('/note/${note.id}'),
                onDelete: note.id == null
                    ? null
                    : () => ref.read(notesProvider.notifier).remove(note.id!),
              );
            },
          );
        },
      ),
    );
  }
}

/// Dipanggil tombol sync. Bila offline, sync ditunda (data tetap aman lokal).
Future<void> syncNow(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final synced = await syncIfOnline(
    offline: container.read(forceOfflineProvider),
    repo: container.read(noteRepositoryProvider),
  );
  container.invalidate(notesProvider);
  messenger.showSnackBar(SnackBar(
    duration: const Duration(seconds: 8),
    content: Text(synced == null
        ? 'Offline: sinkronisasi ditunda, catatan tetap tersimpan lokal.'
        : synced == 0
            ? 'Semua catatan sudah tersinkron.'
            : '$synced catatan berhasil disinkronkan.'),
  ));
}

Future<void> showAddNoteDialog(
  BuildContext context, {
  String initialTitle = '',
  String initialBody = '',
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final title = TextEditingController(text: initialTitle);
  final body = TextEditingController(text: initialBody);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tambah catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: title,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Judul'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: body,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Isi'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
  if (ok == true && title.text.trim().isNotEmpty) {
    await container
        .read(notesProvider.notifier)
        .add(title.text.trim(), body.text.trim());
  }
}
