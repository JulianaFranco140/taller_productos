# Taller Integrador 2 + 3 · Persistencia y sincronización

App Flutter que consulta un catálogo de productos y permite guardar una **prioridad (1 a 5)** y una **nota personal** por producto. Usa HTTP/JSON, un Repository, Drift y Firestore.

## Integrantes

| Integrante | Responsabilidad |
|---|---|
| Juliana Franco Alzate | Integrante 1: catálogo, detalle, validación y botón Sincronizar pendientes |
| Samuel David Gallego Meneses | Integrante 2: Drift, Repository offline-first y Firestore |

## Cómo ejecutarlo

Para que cualquier equipo corra el proyecto. Hace falta:

- Flutter en el PATH, con Dart 3.12 o superior (`flutter --version`).
- Android SDK (Android Studio).
- Internet. El catálogo se descarga de `https://dummyjson.com/products?limit=30&select=title,category,price,thumbnail` y las notas se sincronizan con Firestore del proyecto `taller-movil2`. Esa configuración ya viene en el repositorio (`lib/firebase_options.dart` y `android/app/google-services.json`).

Dentro de la carpeta del proyecto:

```bash
flutter pub get
```

Abre un emulador desde Android Studio (Device Manager) o conecta un celular con la depuración USB activada. Luego:

```bash
flutter devices
flutter run -d <id>
```

`<id>` es el identificador que muestra `flutter devices`, por ejemplo `emulator-5554` o el del celular.

Para correr las pruebas del servicio, la regla de prioridad, Drift, el repository y las pantallas:

```bash
flutter test
```

`lib/database/app_database.g.dart` ya está en el repositorio. Para ejecutar la app no hace falta volver a generar código con `build_runner`.

## Estructura

```
lib/
  main.dart                               crea el repository y lo pasa a MyApp → ProductScreen
  models/product.dart                     Product + fromJson
  models/product_note.dart                ProductNote (productId, note, priority, updatedAt, pendingSync)
  services/product_service.dart           HTTP: timeout, códigos no exitosos, error de red, formato
  database/app_database.dart              tabla ProductNotes en Drift
  database/database_connection.dart        abre product_notes.sqlite
  database/app_database.g.dart             código generado por build_runner
  repository/product_repository.dart      contrato que usa la UI
  repository/offline_first_product_repository.dart   guarda en Drift y luego sube
  repository/remote_note_store.dart        contrato de la subida
  repository/cloud_firestore.dart          sube a la colección product_notes
  repository/in_memory_product_repository.dart   implementación falsa para probar la UI
  firebase_options.dart                    configuración del proyecto taller-movil2
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

## Respuestas

### ¿Para qué sirve pendingSync?

Sirve para controlar si una nota ya se subió a la base de datos (Firestore) o sigue pendiente.Cada producto tiene `true` o `false`. Si el envío funciona, pasa a `false` y se sabe que el proceso acabó  y se subio. Si queda en `true`, por internet o por cualquier fallo de Firebase, al presionar el boton sincronizar  se suben solo esas notas. La nota ya está guardada en el celular.

### ¿Por qué se guarda primero en Drift?

Para conservar la nota en el celular. Si se enviara primero a Firebase y ese envío fallara, la nota no quedaría guardada en ningún lado. Guardando primero en Drift, aunque no haya internet y no se pueda conectar con Firebase, la nota sigue en el celular y se puede volver a leer.

### ¿Qué función cumple el Repository?

Hace de puente entre la interfaz y Drift,firestore para mantener los datos consistentes. La pantalla solo llama el método y le pasa lo que ese método pide. No ve el proceso de Drift ni el de Firebase: para la app es una función que devuelve el resultado. Así se evita mandar los datos al lugar equivocado o no saber a qué base van.

### ¿Qué ocurre si Firebase falla?

Queda el guardado local de `saveNote` en el celular. El sistema avisa que Firebase falló, no que se perdió la nota ya que quedo guardada en el celular. Como `pendingSync` queda en `true`, la app sabe que esa nota todavía se tiene que subir. El botón sincronizar se encarga de subir las que quedaron en el celular cuando Firebase falla.
