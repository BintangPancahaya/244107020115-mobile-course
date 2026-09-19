import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_providers.dart';
import '../data/providers.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(id));
    final commentsAsync = ref.watch(commentsProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text('Detail Post #$id')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(postDetailProvider(id)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (post) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(post.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('User ID: ${post.userId}',
                style: Theme.of(context).textTheme.labelLarge),
            const Divider(height: 32),
            Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
            const Divider(height: 32),
            Text('Komentar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...commentsAsync.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (err, _) => [Text(friendlyErrorMessage(err))],
              data: (comments) => comments.isEmpty
                  ? const [Text('Belum ada komentar.')]
                  : comments
                      .map((c) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.comment_outlined),
                            title: Text(c.name,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('${c.email}\n${c.body}',
                                maxLines: 3, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
