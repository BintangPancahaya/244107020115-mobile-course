import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app/home_shell.dart';
import 'core/format.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';

const routeHome = '/';
const routeNoteDetail = '/note/:id';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(path: routeHome, builder: (context, state) => const HomeShell()),
    GoRoute(
      path: routeNoteDetail,
      builder: (context, state) =>
          NoteDetailPage(id: parseNoteId(state.pathParameters['id']) ?? 0),
    ),
  ],
);
