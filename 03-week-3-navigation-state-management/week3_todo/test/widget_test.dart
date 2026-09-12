import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/main.dart';
import 'package:week3_todo/pages/product_page.dart';
import 'package:week3_todo/providers/stats_provider.dart';
import 'package:week3_todo/providers/todo_provider.dart';
import 'package:week3_todo/widgets/todo_tile.dart';

class _FailingProductsNotifier extends ProductsNotifier {
  static int calls = 0;

  @override
  Future<List<String>> build() async {
    calls++;
    await Future.delayed(const Duration(seconds: 2));
    throw Exception('Gagal terhubung ke server');
  }
}

void main() {
  // Test dari modul praktikum.
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    // Modul memakai pump(), tapi dialog masih beranimasi menutup sehingga
    // teks juga ditemukan di TextField (2 widget). pumpAndSettle menunggu
    // dialog benar-benar hilang.
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('detail, filter, dan statistik memakai state yang sama',
      (tester) async {
    // Statistik memakai simulasi acak (AI Challenge); dipaksa sukses agar
    // test deterministik.
    await tester.pumpWidget(ProviderScope(
      overrides: [statsRandomProvider.overrideWithValue(() => 0.9)],
      child: const MyApp(),
    ));

    for (final title in ['Belajar GoRouter', 'Belajar Riverpod']) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();
    }

    // Buka detail (/todo/:id) lalu tandai selesai.
    await tester.tap(find.text('Belajar GoRouter'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Tugas'), findsOneWidget);
    await tester.tap(find.text('Tandai selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Tandai belum selesai'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Filter "Aktif" hanya menampilkan tugas yang belum selesai.
    await tester.tap(find.text('Aktif'));
    await tester.pumpAndSettle();
    expect(find.text('Belajar GoRouter'), findsNothing);
    expect(find.text('Belajar Riverpod'), findsOneWidget);

    // Pindah tab lewat NavigationBar ke /stats.
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    expect(find.text('Progres 50%'), findsOneWidget);
  });

  testWidgets('TodoTile memanggil callback', (tester) async {
    var toggled = false;
    var deleted = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TodoTile(
          todo: Todo(0, 'Tes tile'),
          onToggle: () => toggled = true,
          onDelete: () => deleted = true,
        ),
      ),
    ));

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byTooltip('Hapus'));
    expect(toggled, isTrue);
    expect(deleted, isTrue);
  });

  testWidgets('ProductPage: loading lalu success', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ProductPage())));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Keyboard'), findsOneWidget);
    expect(find.text('Monitor'), findsOneWidget);
  });

  testWidgets('ProductPage: error lalu Coba lagi menjalankan ulang provider',
      (tester) async {
    _FailingProductsNotifier.calls = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productsProvider.overrideWith(_FailingProductsNotifier.new),
      ],
      child: const MaterialApp(home: ProductPage()),
    ));

    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Gagal memuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(_FailingProductsNotifier.calls, 1);

    await tester.tap(find.text('Coba lagi'));
    await tester.pump(const Duration(seconds: 2));
    expect(_FailingProductsNotifier.calls, 2);
    expect(find.textContaining('Gagal memuat'), findsOneWidget);
  });
}
