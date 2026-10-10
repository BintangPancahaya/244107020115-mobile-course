import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simulasi offline deterministik (dipakai fitur notes & posts).
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);
