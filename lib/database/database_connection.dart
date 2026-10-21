import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

// El archivo vive en el directorio privado de la app, así que las notas
// siguen ahí al cerrarla. Las pruebas no usan esto: abren una base en memoria.
AppDatabase openAppDatabase() {
  return AppDatabase(
    LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'product_notes.sqlite'));
      return NativeDatabase.createInBackground(file);
    }),
  );
}
