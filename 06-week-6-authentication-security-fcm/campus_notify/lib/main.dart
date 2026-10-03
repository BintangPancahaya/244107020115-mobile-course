import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Router dievaluasi ulang setiap status login berubah.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (previous, next) => refresh.value++);
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: routeHome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      return authRedirect(
        loggedIn: auth.isLoading ? null : (auth.value ?? false),
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: routeLogin, builder: (context, state) => const LoginPage()),
      GoRoute(path: routeHome, builder: (context, state) => const HomePage()),
      GoRoute(
        path: routeAnnouncementPattern,
        builder: (context, s) =>
            AnnouncementPage(id: s.pathParameters['id'] ?? ''),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase belum dikonfigurasi untuk platform ini; aplikasi tetap jalan.
  }
  runApp(const ProviderScope(child: CampusApp()));
}

class CampusApp extends ConsumerStatefulWidget {
  const CampusApp({super.key, this.enablePush = true});

  final bool enablePush;

  @override
  ConsumerState<CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends ConsumerState<CampusApp> {
  @override
  void initState() {
    super.initState();
    if (widget.enablePush) Future.microtask(_initPush);
  }

  Future<void> _initPush() async {
    final status = await initPush(
      onToken: (token) async {
        try {
          await ref.read(apiClientProvider).post('/devices', data: {
            'fcm_token': token,
            'platform': defaultTargetPlatform.name,
          });
        } catch (_) {
          // Backend kampus belum tersedia; token tetap tercatat di status.
        }
      },
      go: (route) => ref.read(routerProvider).go(route),
    );
    if (mounted) ref.read(pushStatusProvider.notifier).set(status);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify - Week 6',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
