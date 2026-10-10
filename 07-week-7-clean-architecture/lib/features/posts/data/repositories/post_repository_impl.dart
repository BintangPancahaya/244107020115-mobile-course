// Konstruktor mengikuti pola modul (field privat + initializer list).
// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required Dio dio,
    required Future<Database> Function() openDb,
  })  : _dio = dio,
        _openDb = openDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  @override
  Future<({List<Post> posts, DateTime? cachedAt, Failure? failure})>
      readCached() async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      final posts = rows.map((r) {
        final decoded = jsonDecode(r['payload'] as String? ?? '{}');
        return PostModel.fromJson(
                decoded is Map<String, dynamic> ? decoded : const {})
            .toEntity();
      }).toList();
      final t = await db.rawQuery('SELECT MAX(cached_at) AS t FROM cached_posts');
      return (
        posts: posts,
        cachedAt: DateTime.tryParse(t.first['t'] as String? ?? ''),
        failure: null,
      );
    } catch (e) {
      return (
        posts: const <Post>[],
        cachedAt: null,
        failure: LocalFailure('Gagal membaca cache: $e'),
      );
    }
  }

  @override
  Future<({List<Post> posts, Failure? failure})> refreshFromNetwork() async {
    try {
      final res = await _dio.get<List>('/posts');
      final models = (res.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PostModel.fromJson)
          .toList();
      final db = await _openDb();
      final now = DateTime.now().toIso8601String();
      final batch = db.batch();
      for (final m in models) {
        batch.insert(
          'cached_posts',
          {'id': m.id, 'payload': jsonEncode(m.toJson()), 'cached_at': now},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      return (posts: models.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException {
      return (
        posts: const <Post>[],
        failure: const NetworkFailure(
            'Gagal refresh dari jaringan, menampilkan cache lokal.'),
      );
    } catch (e) {
      return (posts: const <Post>[], failure: LocalFailure('Gagal menyimpan cache: $e'));
    }
  }
}
