import 'package:campus_notify/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginPage menampilkan form email dan kata sandi', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginPage())));
    await tester.pumpAndSettle();
    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Masuk'), findsOneWidget);
  });
}
