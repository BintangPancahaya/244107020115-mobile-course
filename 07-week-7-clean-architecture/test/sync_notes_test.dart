import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/core/failures.dart';
import 'package:week7_clean_architecture/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean_architecture/features/notes/domain/usecases/sync_notes.dart';

class FakeSyncRepository implements NoteSyncRepository {
  FakeSyncRepository(this.dirty);
  int dirty;
  bool marked = false;

  @override
  Future<({int count, Failure? failure})> countDirty() async =>
      (count: dirty, failure: null);

  @override
  Future<Failure?> markAllSynced() async {
    marked = true;
    dirty = 0;
    return null;
  }
}

Future<void> _noUpload() async {}

void main() {
  test('SyncNotes offline -> NetworkFailure dan antrean tetap', () async {
    final repo = FakeSyncRepository(2);
    final result = await SyncNotes(repo, upload: _noUpload).call(offline: true);
    expect(result.failure, isA<NetworkFailure>());
    expect(repo.marked, isFalse);
    expect(repo.dirty, 2);
  });

  test('SyncNotes online -> semua dirty ditandai bersih', () async {
    final repo = FakeSyncRepository(2);
    final result = await SyncNotes(repo, upload: _noUpload).call(offline: false);
    expect(result.failure, isNull);
    expect(result.synced, 2);
    expect(repo.dirty, 0);
  });
}
