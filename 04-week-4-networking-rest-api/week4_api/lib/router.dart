import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/post_list_page.dart';

/// Lokasi awal bisa diatur lewat --dart-define=START=/post/1
/// (dipakai untuk membuka halaman detail secara langsung).
const _start = String.fromEnvironment('START', defaultValue: '/');

final appRouter = GoRouter(
  initialLocation: _start,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const PostListPage()),
    GoRoute(
        path: '/paged', builder: (context, state) => const PagedPostPage()),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) => PostDetailPage(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      ),
    ),
  ],
);
