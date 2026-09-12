import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref
        .watch(todoListProvider)
        .where((t) => t.id == id)
        .firstOrNull;

    if (todo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Center(child: Text('Tugas tidak ditemukan')),
      );
    }

    final notifier = ref.read(todoListProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(
                todo.done ? Icons.check_circle : Icons.pending,
                size: 18,
              ),
              label: Text(todo.done ? 'Selesai' : 'Belum selesai'),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => notifier.toggle(id),
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(
                      todo.done ? 'Tandai belum selesai' : 'Tandai selesai'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    notifier.remove(id);
                    context.pop();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
