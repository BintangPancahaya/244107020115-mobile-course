/// Semua string rute di satu tempat (refactoring) agar deep link FCM dan
/// GoRouter memakai konstanta yang sama.
const routeLogin = '/login';
const routeHome = '/';
const routeAnnouncementPattern = '/pengumuman/:id';
const topicPengumuman = 'pengumuman-kampus';

String announcementRoute(String id) => '/pengumuman/$id';

/// Guard route murni (mudah diuji). [loggedIn] null = status sesi masih dimuat.
String? authRedirect({required bool? loggedIn, required String location}) {
  if (loggedIn == null) return null;
  final goingLogin = location == routeLogin;
  if (!loggedIn && !goingLogin) return routeLogin;
  if (loggedIn && goingLogin) return routeHome;
  return null;
}
