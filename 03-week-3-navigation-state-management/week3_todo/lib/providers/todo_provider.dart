import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.id, this.title, {this.done = false});
  final int id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(id, title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  int _nextId = 0;

  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(_nextId++, title)];

  void toggle(int id) => state = [
        for (final t in state)
          if (t.id == id) t.copyWith(done: !t.done) else t,
      ];

  void remove(int id) => state = state.where((t) => t.id != id).toList();
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

enum TodoFilter { all, active, done }

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void set(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

/// Provider turunan: daftar tugas setelah difilter.
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return switch (ref.watch(todoFilterProvider)) {
    TodoFilter.all => todos,
    TodoFilter.active => todos.where((t) => !t.done).toList(),
    TodoFilter.done => todos.where((t) => t.done).toList(),
  };
});

/// Statistik turunan dari todoListProvider, otomatis ikut berubah.
class TodoStats {
  const TodoStats({required this.total, required this.done});
  final int total;
  final int done;

  int get pending => total - done;
  double get progress => total == 0 ? 0 : done / total;
}

final todoStatsProvider = Provider<TodoStats>((ref) {
  final todos = ref.watch(todoListProvider);
  return TodoStats(
    total: todos.length,
    done: todos.where((t) => t.done).length,
  );
});

class ProductsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi network
    return ['Keyboard', 'Mouse', 'Monitor'];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<List<String>> _fetch() async {
    await Future.delayed(const Duration(seconds: 1));
    return ['Keyboard', 'Mouse', 'Monitor', 'Headset'];
  }
}

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<String>>(
  ProductsNotifier.new,
  // Riverpod 3 otomatis me-retry provider yang error; dimatikan agar
  // state error langsung tampil dan tombol "Coba lagi" yang mengontrol.
  retry: (retryCount, error) => null,
);
