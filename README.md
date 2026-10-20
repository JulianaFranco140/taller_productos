# Taller Integrador 2 + 3 · Persistencia y sincronización

App Flutter que consulta un catálogo de productos y permite guardar una **prioridad (1 a 5)** y una **nota personal** por producto. Usa HTTP/JSON, un Repository, Drift y Firestore.

## Integrantes

| Integrante | Responsabilidad |
|---|---|
| _Nombre completo_ | Integrante 1: catálogo, detalle, validación y botón Sincronizar pendientes |
| _Nombre completo_ | Integrante 2: Drift, Repository offline-first y Firestore |

## Cómo ejecutarlo

```bash
fvm flutter pub get
./scripts/run_android.sh      # enciende el emulador Android y ejecuta la app
fvm flutter test              # pruebas del servicio, la regla, el repository y las pantallas
```

El catálogo se descarga de `https://dummyjson.com/products?limit=30&select=title,category,price,thumbnail`, así que el emulador necesita internet.

## Estructura

```
lib/
  main.dart                               crea el repository y lo pasa a MyApp → ProductScreen
  models/product.dart                     Product + fromJson
  models/product_note.dart                ProductNote (productId, note, priority, updatedAt, pendingSync)
  services/product_service.dart           HTTP: timeout, códigos no exitosos, error de red, formato
  repository/product_repository.dart      contrato que usa la UI
  repository/in_memory_product_repository.dart   implementación falsa para probar la UI
  utils/priority_rule.dart                regla: prioridad >= 2
  screens/product_screen.dart             lista: carga, error + Reintentar, vacío, datos, Sincronizar pendientes
  screens/product_detail_screen.dart      detalle: prioridad, nota, Guardar y estado de sincronización
  widgets/product_card.dart               tarjeta reutilizable + imagen con carga y error
  widgets/sync_status_chip.dart           Sincronizado / Pendiente / Sin información guardada
```

## Contrato con el Integrante 2

La interfaz solo usa esta clase abstracta (`lib/repository/product_repository.dart`):

```dart
abstract class ProductRepository {
  Future<ProductNote?> getNote(int productId);
  Future<void> saveNote(ProductNote note);
  Future<void> syncPending();
}
```

Para conectar Drift y Firestore:

1. Crear la implementación real, por ejemplo `class OfflineFirstProductRepository implements ProductRepository`, que guarde primero en Drift con `pendingSync = true`, intente subir a Firestore (`doc(productId).set(note.toJson())`) y, si sale bien, marque `pendingSync = false`.
2. `getNote` debe devolver el `ProductNote` con el `pendingSync` que esté guardado en Drift. El detalle lo usa para mostrar el estado.
3. En `main.dart`, inicializar Firebase y reemplazar `InMemoryProductRepository()` por la implementación real. No hay que cambiar ninguna pantalla.

## Preguntas

> El enunciado pide responderlas **con sus propias palabras**. Las completa la pareja.

1. **¿Para qué sirve pendingSync?**

2. **¿Por qué se guarda primero en Drift?**

3. **¿Qué función cumple el Repository?**

4. **¿Qué ocurre si Firebase falla?**
