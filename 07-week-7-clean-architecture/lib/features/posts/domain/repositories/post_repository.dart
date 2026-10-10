import '../../../../core/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  /// Cache lokal (cached_posts) - selalu tersedia walau offline.
  Future<({List<Post> posts, DateTime? cachedAt, Failure? failure})> readCached();

  /// Ambil dari jaringan lalu simpan ke cache.
  Future<({List<Post> posts, Failure? failure})> refreshFromNetwork();
}
