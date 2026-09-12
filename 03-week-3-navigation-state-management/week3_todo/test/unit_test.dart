import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('TodoListNotifier', () {
    test('awalnya kosong', () {
      expect(container.read(todoListProvider), isEmpty);
    });

    test('add, toggle, remove berdasarkan id', () {
      final notifier = container.read(todoListProvider.notifier);

      notifier.add('Belajar GoRouter');
      notifier.add('Belajar Riverpod');
      final first = container.read(todoListProvider).first;

      notifier.toggle(first.id);
      expect(container.read(todoListProvider).first.done, isTrue);

      notifier.remove(first.id);
      expect(container.read(todoListProvider).single.title,
          'Belajar Riverpod');
    });

    test('state baru adalah list baru (immutable)', () {
      final notifier = container.read(todoListProvider.notifier);
      notifier.add('A');
      final before = container.read(todoListProvider);
      notifier.toggle(before.first.id);
      expect(identical(before, container.read(todoListProvider)), isFalse);
      expect(before.first.done, isFalse);
    });
  });

  test('filteredTodoListProvider mengikuti filter', () {
    final notifier = container.read(todoListProvider.notifier);
    notifier
      ..add('A')
      ..add('B');
    notifier.toggle(container.read(todoListProvider).first.id);

    final filter = container.read(todoFilterProvider.notifier);
    filter.set(TodoFilter.active);
    expect(container.read(filteredTodoListProvider).map((t) => t.title),
        ['B']);
    filter.set(TodoFilter.done);
    expect(container.read(filteredTodoListProvider).map((t) => t.title),
        ['A']);
    filter.set(TodoFilter.all);
    expect(container.read(filteredTodoListProvider).length, 2);
  });

  test('todoStatsProvider menghitung total, selesai, dan progres', () {
    final notifier = container.read(todoListProvider.notifier);
    notifier
      ..add('A')
      ..add('B');
    notifier.toggle(container.read(todoListProvider).first.id);

    final stats = container.read(todoStatsProvider);
    expect(stats.total, 2);
    expect(stats.done, 1);
    expect(stats.pending, 1);
    expect(stats.progress, 0.5);
  });

  test('productsProvider berakhir di AsyncData', () async {
    final products = await container.read(productsProvider.future);
    expect(products, ['Keyboard', 'Mouse', 'Monitor']);
    expect(container.read(productsProvider), isA<AsyncData<List<String>>>());
  });
}
