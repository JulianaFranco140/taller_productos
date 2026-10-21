import '../models/product_note.dart';

// Contrato entre la interfaz y los datos personales de cada producto.
// La UI solo conoce estos tres métodos; no sabe si detrás hay memoria,
// Drift o Firestore. El Integrante 2 lo implementa con Drift + Firestore.
abstract class ProductRepository {
  // Nota guardada del producto, o null si nunca se ha guardado.
  Future<ProductNote?> getNote(int productId);

  // Guarda (o reemplaza) la nota del producto. Queda con pendingSync = true
  // hasta que el envío remoto se confirme.
  Future<void> saveNote(ProductNote note);

  // Intenta enviar únicamente las notas con pendingSync == true.
  Future<void> syncPending();

  // Texto del último fallo de Firebase. Null si el último envío salió bien.
  String? get lastRemoteError;
}
