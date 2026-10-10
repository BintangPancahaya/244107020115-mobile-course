import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/toggle_dark_mode.dart';

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => SettingsRepositoryImpl());

final toggleDarkModeProvider = Provider<ToggleDarkMode>(
    (ref) => ToggleDarkMode(ref.watch(settingsRepositoryProvider)));

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(settingsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    state = await AsyncValue.guard(() => ref.read(toggleDarkModeProvider).call());
  }
}

final lastOpenedProvider = FutureProvider<DateTime?>(
    (ref) => ref.watch(settingsRepositoryProvider).getLastOpened());
