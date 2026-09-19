import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/network_errors.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang', () {
    final c = Comment.fromJson({'id': 3});
    expect(c.id, 3);
    expect(c.postId, 0);
    expect(c.name, '');
    expect(c.email, '');
    expect(c.body, '');
  });

  // Edge case tambahan (bukan dari AI): tipe data salah dari server.
  test('Comment.fromJson aman terhadap tipe yang salah', () {
    final c = Comment.fromJson({
      'postId': 2.0,
      'id': '9',
      'name': 123,
      'email': null,
      'body': ['bukan string'],
    });
    expect(c.postId, 2);
    expect(c.id, 0);
    expect(c.name, '');
    expect(c.email, '');
    expect(c.body, '');
  });

  test('friendlyErrorMessage memetakan 404 dan 500', () {
    DioException bad(int code) => DioException(
          requestOptions: RequestOptions(path: '/comments'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/comments'),
            statusCode: code,
          ),
        );
    expect(friendlyErrorMessage(bad(404)), contains('404'));
    expect(friendlyErrorMessage(bad(500)), contains('500'));
  });

  test('friendlyErrorMessage memetakan timeout', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      type: DioExceptionType.receiveTimeout,
    );
    expect(friendlyErrorMessage(err), contains('timeout'));
  });
}
