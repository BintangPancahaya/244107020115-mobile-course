import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/connectivity.dart';
import '../../../../shared/database/db.dart';
import '../../data/remote/http_client.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(dio: buildPostsHttpClient(), openDb: openNotesDb);
});

class CachedPostsState {
  const CachedPostsState({
    this.posts = const [],
    this.cachedAt,
    this.refreshing = false,
    this.message,
  });

  final List<Post> posts;
  final DateTime? cachedAt;
  final bool refreshing;
  final String? message;
}

/// Cache-first: cache tampil seketika, refresh jaringan di background.
/// Tanpa use case: hanya meneruskan dua operasi repository (alasan di docs).
class CachedPostsNotifier extends AsyncNotifier<CachedPostsState> {
  @override
  Future<CachedPostsState> build() async {
    final cached = await ref.watch(postRepositoryProvider).readCached();
    if (cached.failure != null) throw cached.failure!;
    return CachedPostsState(posts: cached.posts, cachedAt: cached.cachedAt);
  }

  Future<void> refreshInBackground() async {
    final current = await future;
    if (!ref.mounted) return;
    if (ref.read(forceOfflineProvider)) {
      state = AsyncData(CachedPostsState(
        posts: current.posts,
        cachedAt: current.cachedAt,
        message: 'Mode offline: menampilkan cache lokal.',
      ));
      return;
    }
    state = AsyncData(CachedPostsState(
        posts: current.posts, cachedAt: current.cachedAt, refreshing: true));
    final result = await ref.read(postRepositoryProvider).refreshFromNetwork();
    if (!ref.mounted) return;
    state = AsyncData(result.failure == null
        ? CachedPostsState(posts: result.posts, cachedAt: DateTime.now())
        : CachedPostsState(
            posts: current.posts,
            cachedAt: current.cachedAt,
            message: result.failure!.message,
          ));
  }
}

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, CachedPostsState>(
  CachedPostsNotifier.new,
  retry: (retryCount, error) => null,
);
