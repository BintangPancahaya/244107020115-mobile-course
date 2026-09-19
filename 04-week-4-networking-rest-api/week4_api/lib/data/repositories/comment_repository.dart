import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository = satu-satunya pintu data comment. UI tidak menyentuh Dio.
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  /// GET /comments?postId={id}. Timeout 10 detik tidak ditulis ulang di
  /// sini karena sudah terpusat di createDio() (api_client.dart).
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
