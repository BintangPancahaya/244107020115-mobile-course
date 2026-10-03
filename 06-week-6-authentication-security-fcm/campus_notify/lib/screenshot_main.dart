import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main.dart';
import 'messaging/push_service.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

/// Entrypoint KHUSUS dokumentasi screenshot di Chrome:
///   flutter run -t lib/screenshot_main.dart --dart-define=SCENE=NAMA_SCENE
/// Scene: login (form terisi), beranda (sudah login lewat AuthRepository +
/// TokenStore asli), detail (deep link /pengumuman/3 diproses lewat
/// routeFromMessage, sama seperti klik notifikasi).
const scene = String.fromEnvironment('SCENE', defaultValue: 'login');
const _email = 'bintang@student.polinema.ac.id';
const _password = 'rahasia123';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Sama seperti main.dart: Firebase belum dikonfigurasi di Web.
  }
  final container = ProviderContainer(overrides: [
    loginPrefillProvider.overrideWithValue(
        scene == 'login' ? (_email, _password) : ('', '')),
  ]);
  final store = container.read(tokenStoreProvider);
  await store.clear();
  if (scene != 'login') {
    final session = await container
        .read(authRepositoryProvider)
        .login(email: _email, password: _password);
    await store.save(access: session.access, refresh: session.refresh);
  }

  runApp(UncontrolledProviderScope(
      container: container, child: const CampusApp()));

  if (scene == 'detail') {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      // Payload data yang sama dengan contoh pesan FCM pada modul.
      final route = routeFromMessage({'route': '/pengumuman/3', 'id': '3'});
      container.read(routerProvider).push(route);
    });
  }
}
