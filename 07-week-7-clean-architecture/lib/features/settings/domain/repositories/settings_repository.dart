/// Kontrak preferensi (domain). Implementasi SharedPreferences ada di data.
abstract class SettingsRepository {
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
  Future<void> markOpenedNow();
  Future<DateTime?> getLastOpened();
}
