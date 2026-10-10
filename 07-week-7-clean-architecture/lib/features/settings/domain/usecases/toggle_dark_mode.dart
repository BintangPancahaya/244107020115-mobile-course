import '../repositories/settings_repository.dart';

/// Membalik tema berdasarkan nilai TERSIMPAN (bukan state UI), lalu menyimpan.
class ToggleDarkMode {
  const ToggleDarkMode(this._repository);
  final SettingsRepository _repository;

  Future<bool> call() async {
    final next = !(await _repository.getDarkMode());
    await _repository.setDarkMode(next);
    return next;
  }
}
