import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';

// ---------------------------------------------------------------------------
// Simulasi offline deterministik (toggle forceOffline)
// ---------------------------------------------------------------------------
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// ---------------------------------------------------------------------------
// Sinkronisasi catatan dirty
// Aturan konflik: last-write-wins berdasarkan updated_at.
// ---------------------------------------------------------------------------
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

/// Mengembalikan null bila offline (sync ditunda, data tetap aman lokal).
Future<int?> syncIfOnline({
  required bool offline,
  required NoteRepository repo,
}) async {
  if (offline) return null;
  return syncNotes(repo);
}

// ---------------------------------------------------------------------------
// Cache-first untuk data bacaan (GET /posts JSONPlaceholder)
// ---------------------------------------------------------------------------
class PostCache {
  PostCache({Future<Database> Function()? openDb, Dio? dio})
      : _openDb = openDb ?? openNotesDb,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Future<Database> Function() _openDb;
  final Dio _dio;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((r) {
      final decoded = jsonDecode(r['payload'] as String? ?? '{}');
      return Post.fromJson(
          decoded is Map<String, dynamic> ? decoded : const {});
    }).toList();
  }

  Future<DateTime?> lastCachedAt() async {
    final db = await _openDb();
    final rows =
        await db.rawQuery('SELECT MAX(cached_at) AS t FROM cached_posts');
    return DateTime.tryParse(rows.first['t'] as String? ?? '');
  }

  Future<List<Post>> fetchAndCache() async {
    final res = await _dio.get<List>('/posts');
    final posts = (res.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
    final db = await _openDb();
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {'id': post.id, 'payload': jsonEncode(post.toJson()), 'cached_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    return posts;
  }
}

final postCacheProvider = Provider<PostCache>((ref) => PostCache());

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

class CachedPostsNotifier extends AsyncNotifier<CachedPostsState> {
  /// 1. Segera kembalikan cache agar UI tidak blank saat offline.
  @override
  Future<CachedPostsState> build() async {
    final cache = ref.watch(postCacheProvider);
    final cached = await cache.readCachedPosts();
    final at = await cache.lastCachedAt();
    return CachedPostsState(posts: cached, cachedAt: at);
  }

  /// 2. Di background: fetch Dio -> simpan ke cached_posts -> perbarui state.
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
    try {
      final fresh = await ref.read(postCacheProvider).fetchAndCache();
      if (!ref.mounted) return;
      state = AsyncData(
          CachedPostsState(posts: fresh, cachedAt: DateTime.now()));
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(CachedPostsState(
        posts: current.posts,
        cachedAt: current.cachedAt,
        message: 'Gagal refresh dari jaringan, menampilkan cache lokal.',
      ));
    }
  }
}

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, CachedPostsState>(
  CachedPostsNotifier.new,
  retry: (retryCount, error) => null,
);
