import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/pages/stats_page.dart';
import 'package:week3_todo/providers/stats_provider.dart';
import 'package:week3_todo/providers/todo_provider.dart';

/// Container dengan delay 0 dan angka acak yang ditentukan test.
ProviderContainer _container(List<double> rolls) {
  var i = 0;
  return ProviderContainer(overrides: [
    statsDelayProvider.overrideWithValue(Duration.zero),
    statsRandomProvider.overrideWithValue(() => rolls[i++ % rolls.length]),
  ]);
}

void main() {
  group('StatsNotifier (unit)', () {
    test('sukses: statistik sesuai daftar tugas', () async {
      final c = _container([0.9]);
      addTearDown(c.dispose);
      final todos = c.read(todoListProvider.notifier)
        ..add('A')
        ..add('B');
      todos.toggle(c.read(todoListProvider).first.id);

      final stats = await c.read(statsProvider.future);
      expect(stats.total, 2);
      expect(stats.done, 1);
      expect(stats.pending, 1);
      expect(stats.progress, 0.5);
    });

    test('gagal (angka acak < 0.3) menjadi AsyncError', () async {
      final c = _container([0.1]);
      addTearDown(c.dispose);
      await expectLater(
          c.read(statsProvider.future), throwsA(isA<StatsException>()));
      expect(c.read(statsProvider).hasError, isTrue);
    });

    test('batas 30%: 0.3 dihitung sukses', () async {
      final c = _container([0.3]);
      addTearDown(c.dispose);
      expect((await c.read(statsProvider.future)).total, 0);
    });

    test('retry setelah gagal menjalankan ulang lalu sukses', () async {
      final c = _container([0.1, 0.9]);
      addTearDown(c.dispose);
      await expectLater(
          c.read(statsProvider.future), throwsA(isA<StatsException>()));

      c.invalidate(statsProvider);
      final stats = await c.read(statsProvider.future);
      expect(stats.total, 0);
      expect(c.read(statsProvider).hasValue, isTrue);
    });

    test('statistik diambil ulang saat daftar tugas berubah', () async {
      final c = _container([0.9]);
      addTearDown(c.dispose);
      final sub = c.listen(statsProvider, (_, _) {});
      addTearDown(sub.close);
      expect((await c.read(statsProvider.future)).total, 0);

      c.read(todoListProvider.notifier).add('Baru');
      expect((await c.read(statsProvider.future)).total, 1);
    });
  });

  group('StatsPage (widget)', () {
    Widget app(List<double> rolls) {
      var i = 0;
      return ProviderScope(
        overrides: [
          statsRandomProvider.overrideWithValue(() => rolls[i++ % rolls.length]),
        ],
        child: const MaterialApp(home: StatsPage()),
      );
    }

    testWidgets('loading lalu success menampilkan ListView 3 item',
        (tester) async {
      await tester.pumpWidget(app([0.9]));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('Total tugas'), findsOneWidget);
      expect(find.text('Progres 0%'), findsOneWidget);
    });

    testWidgets('error menampilkan pesan + Coba lagi, lalu sukses',
        (tester) async {
      await tester.pumpWidget(app([0.1, 0.9]));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Gagal mengambil statistik dari server.'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(ListTile), findsNWidgets(3));
    });
  });
}
