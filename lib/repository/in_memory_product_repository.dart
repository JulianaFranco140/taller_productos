import '../models/product_note.dart';
import 'product_repository.dart';

// Repository falso para probar la UI mientras existe el real (Drift + Firestore).
// Los datos se pierden al cerrar la app.
class InMemoryProductRepository implements ProductRepository {
  final Map<int, ProductNote> _notes = {};

  // Permite simular que Firebase falla al sincronizar.
  bool simulateSyncFailure;

  final Duration delay;

  InMemoryProductRepository({
    this.simulateSyncFailure = false,
    this.delay = const Duration(milliseconds: 300),
  });

  @override
  Future<ProductNote?> getNote(int productId) async {
    await Future<void>.delayed(delay);
    return _notes[productId];
  }

  @override
  Future<void> saveNote(ProductNote note) async {
    await Future<void>.delayed(delay);
    // Usar el productId como clave reemplaza el registro anterior: no se duplica.
    _notes[note.productId] = note.copyWith(pendingSync: true);
  }

  @override
  Future<void> syncPending() async {
    await Future<void>.delayed(delay);
    if (simulateSyncFailure) {
      throw Exception('Fallo remoto simulado');
    }
    final pending = _notes.values.where((note) => note.pendingSync).toList();
    for (final note in pending) {
      _notes[note.productId] = note.copyWith(pendingSync: false);
    }
  }
}
