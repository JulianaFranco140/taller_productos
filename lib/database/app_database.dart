import 'package:drift/drift.dart';

import '../models/product_note.dart';

part 'app_database.g.dart';

// Un producto, un registro. productId es la clave: guardar otra vez
// actualiza la misma fila en lugar de crear una segunda.
@DataClassName('ProductNoteRow')
class ProductNotes extends Table {
  IntColumn get productId => integer()();
  TextColumn get note => text()();
  IntColumn get priority => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get pendingSync => boolean()();

  @override
  Set<Column> get primaryKey => {productId};
}

@DriftDatabase(tables: [ProductNotes])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  Future<ProductNote?> getNote(int productId) async {
    final row = await (select(productNotes)
          ..where((table) => table.productId.equals(productId)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // insertOnConflictUpdate usa la clave primaria: si el productId ya existe,
  // reemplaza nota, prioridad, fecha y pendingSync.
  Future<void> upsertNote(ProductNote note) {
    return into(productNotes).insertOnConflictUpdate(
      ProductNotesCompanion(
        productId: Value(note.productId),
        note: Value(note.note),
        priority: Value(note.priority),
        updatedAt: Value(note.updatedAt),
        pendingSync: Value(note.pendingSync),
      ),
    );
  }

  Future<List<ProductNote>> pendingNotes() async {
    final rows = await (select(productNotes)
          ..where((table) => table.pendingSync.equals(true)))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> markSynced(int productId) {
    return (update(productNotes)
          ..where((table) => table.productId.equals(productId)))
        .write(const ProductNotesCompanion(pendingSync: Value(false)));
  }

  ProductNote _toModel(ProductNoteRow row) {
    return ProductNote(
      productId: row.productId,
      note: row.note,
      priority: row.priority,
      updatedAt: row.updatedAt,
      pendingSync: row.pendingSync,
    );
  }
}
