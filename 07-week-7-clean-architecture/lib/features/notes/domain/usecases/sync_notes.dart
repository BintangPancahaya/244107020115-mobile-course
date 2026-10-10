import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Use case karena menggabungkan aturan offline + hitung antrean + upload
/// + tandai bersih. Aturan konflik: last-write-wins berdasarkan updated_at.
class SyncNotes {
  const SyncNotes(this._repository, {this.upload = _simulatedUpload});

  final NoteSyncRepository _repository;

  /// Simulasi upload ke server (belum ada backend tulis).
  final Future<void> Function() upload;

  static Future<void> _simulatedUpload() =>
      Future.delayed(const Duration(seconds: 1));

  Future<({int synced, Failure? failure})> call({required bool offline}) async {
    if (offline) {
      return (
        synced: 0,
        failure: const NetworkFailure(
            'Offline: sinkronisasi ditunda, catatan tetap tersimpan lokal.'),
      );
    }
    final dirty = await _repository.countDirty();
    if (dirty.failure != null) return (synced: 0, failure: dirty.failure);
    if (dirty.count == 0) return (synced: 0, failure: null);
    await upload();
    final marked = await _repository.markAllSynced();
    if (marked != null) return (synced: 0, failure: marked);
    return (synced: dirty.count, failure: null);
  }
}
