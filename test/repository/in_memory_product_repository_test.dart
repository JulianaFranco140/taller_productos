import 'package:flutter_test/flutter_test.dart';
import 'package:taller_productos/models/product_note.dart';
import 'package:taller_productos/repository/in_memory_product_repository.dart';

ProductNote note(int id, String text, int priority) => ProductNote(
  productId: id,
  note: text,
  priority: priority,
  updatedAt: DateTime(2026, 10, 20),
);

void main() {
  late InMemoryProductRepository repository;

  setUp(() => repository = InMemoryProductRepository(delay: Duration.zero));

  test('sin registro devuelve null', () async {
    expect(await repository.getNote(1), isNull);
  });

  test('guardar dos veces reemplaza la nota y queda pendiente', () async {
    await repository.saveNote(note(1, 'primera', 2));
    await repository.syncPending();
    await repository.saveNote(note(1, 'segunda', 4));

    final saved = await repository.getNote(1);
    expect(saved!.note, 'segunda');
    expect(saved.priority, 4);
    expect(saved.pendingSync, isTrue);
  });

  test('syncPending marca las pendientes como sincronizadas', () async {
    await repository.saveNote(note(1, 'a', 3));
    await repository.saveNote(note(2, 'b', 5));

    await repository.syncPending();

    expect((await repository.getNote(1))!.pendingSync, isFalse);
    expect((await repository.getNote(2))!.pendingSync, isFalse);
  });

  test('si la sincronización falla la nota sigue pendiente', () async {
    repository.simulateSyncFailure = true;
    await repository.saveNote(note(1, 'a', 3));

    await expectLater(repository.syncPending(), throwsException);
    expect((await repository.getNote(1))!.pendingSync, isTrue);
  });
}
