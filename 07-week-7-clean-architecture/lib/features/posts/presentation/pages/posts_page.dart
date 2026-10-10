import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/posts_providers.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({super.key});

  @override
  ConsumerState<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends ConsumerState<PostsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cachedPostsProvider.notifier).refreshInBackground();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(cachedPostsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(cachedPostsProvider.notifier).refreshInBackground(),
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(cachedPostsProvider),
        ),
        data: (s) => Column(
          children: [
            if (s.refreshing) const LinearProgressIndicator(),
            ListTile(
              dense: true,
              leading: const Icon(Icons.storage),
              title: Text('${s.posts.length} post di cache lokal'),
              subtitle: Text([
                if (s.cachedAt != null)
                  'Terakhir disimpan ${formatDateTime(s.cachedAt!)}',
                if (s.message != null) s.message!,
              ].join(' - ')),
            ),
            const Divider(height: 1),
            Expanded(
              child: s.posts.isEmpty
                  ? const Center(
                      child: Text('Cache kosong. Hubungkan internet lalu refresh.'))
                  : ListView.builder(
                      itemCount: s.posts.length,
                      itemBuilder: (context, i) => ListTile(
                        leading: CircleAvatar(child: Text('${s.posts[i].id}')),
                        title: Text(s.posts[i].title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
