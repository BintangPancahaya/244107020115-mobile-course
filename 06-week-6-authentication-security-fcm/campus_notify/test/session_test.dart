import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test terhadap kode ASLI aplikasi (tanpa Firebase sungguhan).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('routeFromMessage asli aman untuk payload apa pun', () {
    expect(routeFromMessage({}), routeHome);
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': 3}), routeHome);
  });

  test('authRedirect: belum login selalu ke /login', () {
    expect(authRedirect(loggedIn: false, location: routeHome), routeLogin);
    expect(authRedirect(loggedIn: false, location: '/pengumuman/3'), routeLogin);
    expect(authRedirect(loggedIn: false, location: routeLogin), isNull);
    expect(authRedirect(loggedIn: true, location: routeLogin), routeHome);
    expect(authRedirect(loggedIn: true, location: '/pengumuman/3'), isNull);
    expect(authRedirect(loggedIn: null, location: routeHome), isNull);
  });

  test('shortToken hanya menampilkan 12 karakter pertama', () {
    expect(shortToken('abcdefghijklmnopqrst'), 'abcdefghijkl...');
    expect(shortToken('pendek'), 'pendek');
  });

  test('friendlyApiError memetakan 401 dan offline', () {
    final unauthorized = DioException(
      requestOptions: RequestOptions(path: '/devices'),
      type: DioExceptionType.badResponse,
      response: Response(
          requestOptions: RequestOptions(path: '/devices'), statusCode: 401),
    );
    final offline = DioException(
      requestOptions: RequestOptions(path: '/devices'),
      type: DioExceptionType.connectionError,
    );
    expect(friendlyApiError(unauthorized), contains('login kembali'));
    expect(friendlyApiError(offline), contains('koneksi'));
  });

  test('login sukses menyimpan token di secure storage', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(await container.read(authStateProvider.future), isFalse);
    await container
        .read(authStateProvider.notifier)
        .login('bintang@polinema.ac.id', 'rahasia123');
    expect(container.read(authStateProvider).value, isTrue);
    expect(await container.read(tokenStoreProvider).readRefresh(),
        'mock-refresh-for-bintang@polinema.ac.id');
  });

  test('login gagal tidak menyimpan token', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(authStateProvider.notifier).login('salah', '123');
    expect(container.read(authStateProvider).hasError, isTrue);
    expect(await container.read(tokenStoreProvider).readAccess(), isNull);
  });

  test('logout membersihkan sesi', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container
        .read(authStateProvider.notifier)
        .login('bintang@polinema.ac.id', 'rahasia123');
    await container.read(authStateProvider.notifier).logout();
    expect(await container.read(authStateProvider.future), isFalse);
  });

  test('refresh dengan token kosong gagal -> wajib login ulang', () {
    expect(AuthRepository().refresh(''), throwsException);
  });
}
