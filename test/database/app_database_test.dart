import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taller_productos/database/app_database.dart';
import 'package:taller_productos/models/product_note.dart';

ProductNote sample({
  int productId = 1,
  String note = 'revisar stock',
  int priority = 3,
  bool pendingSync = true,
}) {
  return ProductNote(
    productId: productId,
    note: note,
    priority: priority,
    updatedAt: DateTime.utc(2026, 10, 20, 15, 30),
    pendingSync: pendingSync,
  );
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('sin registro devuelve null', () async {
    expect(await database.getNote(1), isNull);
  });

  test('guardar dos veces el mismo producto deja una sola fila', () async {
    await database.upsertNote(sample(note: 'primera'));
    await database.upsertNote(sample(note: 'segunda', priority: 4));

    final saved = await database.getNote(1);
    final pending = await database.pendingNotes();

    expect(saved!.note, 'segunda');
    expect(saved.priority, 4);
    expect(saved.pendingSync, isTrue);
    expect(pending, hasLength(1));
  });

  test('markSynced deja el registro fuera de los pendientes', () async {
    await database.upsertNote(sample());
    await database.markSynced(1);

    final saved = await database.getNote(1);
    expect(saved!.pendingSync, isFalse);
    expect(await database.pendingNotes(), isEmpty);
  });
}
