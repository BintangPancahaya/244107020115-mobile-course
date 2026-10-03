import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes.dart';

final _local = FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

/// Fungsi murni (refactoring): data payload FCM -> rute tujuan.
/// Bisa diunit-test tanpa Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = data['route'];
  final route = raw is String && raw.isNotEmpty ? raw : routeHome;
  return route.startsWith('/') ? route : '/$route';
}

/// Token hanya boleh tampil terpotong (12 karakter pertama + ...).
String shortToken(String token) =>
    token.length <= 12 ? token : '${token.substring(0, 12)}...';

// ANDROID 13+ & iOS: izin notifikasi wajib diminta saat runtime.
Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true, badge: true, sound: true,
    announcement: false, carPlay: false, criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Klik banner foreground -> teruskan payload ke router.
      pendingDeepLink = response.payload;
    },
  );
}

Future<void> initFcmToken(
    {required Future<void> Function(String token) onToken}) async {
  // 1. Ambil token saat ini dan kirim ke backend.
  // Modul memakai getToken; di firebase_messaging 17 API ini deprecated
  // (pengganti: register/onRegistered) tetapi masih berfungsi.
  // ignore: deprecated_member_use
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  // 2. Token bisa berubah (reinstall, clear data, rotasi keamanan).
  //    Listener ini WAJIB ada, jika tidak backend menyimpan token basi.
  // ignore: deprecated_member_use
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  // 3. Langganan topik kampus (mis. semua mahasiswa angkatan).
  await FirebaseMessaging.instance.subscribeToTopic(topicPengumuman);
}

Future<void> unsubscribePengumuman() =>
    FirebaseMessaging.instance.unsubscribeFromTopic(topicPengumuman);

// TIDAK BOLEH akses BuildContext / Riverpod: berjalan di isolate terpisah.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tugasnya: catat / simpan ringan saja. Navigasi dilakukan saat klik.
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

void listenForeground(void Function(String route) go) {
  // Foreground: sistem TIDAK menampilkan banner otomatis,
  // jadi tampilkan manual via local notification.
  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(message.data);
    const androidDetails = AndroidNotificationDetails(
      'pengumuman', 'Pengumuman Kampus',
      importance: Importance.high, priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  // Background -> diklik.
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(routeFromMessage(message.data));
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  // Terminated -> dibuka dari notifikasi.
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(routeFromMessage(initial.data));
  if (pendingDeepLink != null) go(pendingDeepLink!);
}

class PushStatus {
  const PushStatus({this.permission, this.token, this.topic, this.message});
  final bool? permission;
  final String? token;
  final String? topic;
  final String? message;
}

class PushStatusNotifier extends Notifier<PushStatus> {
  @override
  PushStatus build() => const PushStatus(message: 'Menyiapkan FCM...');

  void set(PushStatus value) => state = value;
}

final pushStatusProvider =
    NotifierProvider<PushStatusNotifier, PushStatus>(PushStatusNotifier.new);

/// Menjalankan seluruh alur FCM. Bila Firebase belum dikonfigurasi
/// (mis. belum ada google-services.json / firebase_options), aplikasi tetap
/// jalan dan status dijelaskan di kartu debug.
Future<PushStatus> initPush({
  required Future<void> Function(String token) onToken,
  required void Function(String route) go,
}) async {
  if (Firebase.apps.isEmpty) {
    return const PushStatus(
      topic: topicPengumuman,
      message: 'Firebase belum dikonfigurasi (jalankan flutterfire configure).',
    );
  }
  try {
    if (!kIsWeb) {
      await initLocalNotifications();
      registerBackgroundHandler();
    }
    final granted = await requestNotificationPermission();
    String? current;
    await initFcmToken(onToken: (token) async {
      current = token;
      await onToken(token);
    });
    listenForeground(go);
    await handleTerminated(go);
    return PushStatus(
        permission: granted, token: current, topic: topicPengumuman);
  } catch (e) {
    return PushStatus(topic: topicPengumuman, message: 'FCM gagal: $e');
  }
}
