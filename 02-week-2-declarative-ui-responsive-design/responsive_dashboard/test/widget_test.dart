import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart'; // Sesuaikan nama package jika berbeda

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (tester) async {
    // Override ukuran layar menjadi sempit (400 x 800)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    // Mengambil lebar kartu pertama
    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, lessThan(700));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (tester) async {
    // Override ukuran layar menjadi lebar (1200 x 800)
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    // Mengambil lebar kartu pertama
    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, greaterThan(500));
  });
}