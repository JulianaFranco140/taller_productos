import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taller_productos/database/app_database.dart';
import 'package:taller_productos/models/product_note.dart';
import 'package:taller_productos/repository/offline_first_product_repository.dart';
import 'package:taller_productos/repository/remote_note_store.dart';

class FakeRemoteNoteStore implements RemoteNoteStore {
  bool fail = false;
  final List<int> uploaded = [];

  @override
  Future<void> upload(ProductNote note) async {
    if (fail) throw Exception('Fallo remoto');
    uploaded.add(note.productId);
  }
}

ProductNote sample(int id) => ProductNote(
  productId: id,
  note: 'nota $id',
  priority: 3,
  updatedAt: DateTime.utc(2026, 10, 20, 15, 30),
);

void main() {
  late AppDatabase database;
  late FakeRemoteNoteStore remote;
  late OfflineFirstProductRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    remote = FakeRemoteNoteStore();
    repository = OfflineFirstProductRepository(
      database: database,
      remote: remote,
    );
  });

  tearDown(() => database.close());

  test('si el remoto responde, la nota queda sincronizada', () async {
    await repository.saveNote(sample(1));

    final saved = await repository.getNote(1);
    expect(saved!.pendingSync, isFalse);
    expect(remote.uploaded, [1]);
  });

  test('si el remoto falla, la nota sigue guardada y pendiente', () async {
    remote.fail = true;
    await repository.saveNote(sample(1));

    final saved = await repository.getNote(1);
    expect(saved!.note, 'nota 1');
    expect(saved.pendingSync, isTrue);
  });

  test('syncPending envía solo las pendientes', () async {
    await repository.saveNote(sample(1));
    remote.fail = true;
    await repository.saveNote(sample(2));
    remote.fail = false;
    remote.uploaded.clear();

    await repository.syncPending();

    expect(remote.uploaded, [2]);
    expect((await repository.getNote(1))!.pendingSync, isFalse);
    expect((await repository.getNote(2))!.pendingSync, isFalse);
  });
}