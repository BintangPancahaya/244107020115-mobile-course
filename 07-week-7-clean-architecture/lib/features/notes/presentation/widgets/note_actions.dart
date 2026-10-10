import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/connectivity.dart';
import '../providers/notes_providers.dart';

/// Tombol sync -> use case SyncNotes. UI hanya menampilkan pesan.
Future<void> syncNow(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final result = await container
      .read(syncNotesProvider)
      .call(offline: container.read(forceOfflineProvider));
  container.invalidate(notesProvider);
  messenger.showSnackBar(SnackBar(
    duration: const Duration(seconds: 8),
    content: Text(result.failure?.message ??
        (result.synced == 0
            ? 'Semua catatan sudah tersinkron.'
            : '${result.synced} catatan berhasil disinkronkan.')),
  ));
}

Future<void> deleteNote(BuildContext context, int id) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final failure = await container.read(noteEditRepositoryProvider).deleteNote(id);
  container.invalidate(notesProvider);
  if (failure != null) {
    messenger.showSnackBar(SnackBar(content: Text(failure.message)));
  }
}

Future<void> showAddNoteDialog(
  BuildContext context, {
  String initialTitle = '',
  String initialBody = '',
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
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
  if (ok != true) return;
  final result = await container
      .read(addNoteProvider)
      .call(title: title.text, body: body.text);
  if (result.failure != null) {
    messenger.showSnackBar(SnackBar(content: Text(result.failure!.message)));
  } else {
    container.invalidate(notesProvider);
  }
}
