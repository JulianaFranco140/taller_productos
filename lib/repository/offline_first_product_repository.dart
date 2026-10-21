import '../database/app_database.dart';
import '../models/product_note.dart';
import 'product_repository.dart';
import 'remote_note_store.dart';

class OfflineFirstProductRepository implements ProductRepository {
  final AppDatabase _database;
  final RemoteNoteStore _remote;

  @override
  String? lastRemoteError;

  OfflineFirstProductRepository({
    required AppDatabase database,
    required RemoteNoteStore remote,
  }) : _database = database,
       _remote = remote;

  @override
  Future<ProductNote?> getNote(int productId) {
    return _database.getNote(productId);
  }

  @override
  Future<void> saveNote(ProductNote note) async {
    final pending = note.copyWith(pendingSync: true);
    await _database.upsertNote(pending);
    lastRemoteError = null;
    try {
      await _remote.upload(pending);
      await _database.markSynced(note.productId);
    } catch (error) {
      // La fila ya quedó en Drift con pendingSync = true.
      lastRemoteError = error.toString();
      print('FIRESTORE_ERROR $error');
    }
  }

  @override
  Future<void> syncPending() async {
    final pending = await _database.pendingNotes();
    for (final note in pending) {
      await _remote.upload(note);
      await _database.markSynced(note.productId);
    }
  }
}