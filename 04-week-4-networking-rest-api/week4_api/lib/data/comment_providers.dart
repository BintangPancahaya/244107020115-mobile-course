import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

/// Repository memakai Dio yang sama (dioProvider) agar konfigurasi terpusat.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// AsyncNotifier per postId (family). Exception dari repository otomatis
/// menjadi AsyncError; pesan ramah diambil dari friendlyErrorMessage
/// (timeout, connection error, 404, 500 sudah dipetakan).
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() {
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}

final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
  CommentsNotifier.new,
  retry: (retryCount, error) => null,
);
