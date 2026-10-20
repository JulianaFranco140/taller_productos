import 'package:flutter/material.dart';

import 'repository/in_memory_product_repository.dart';
import 'repository/product_repository.dart';
import 'screens/product_screen.dart';

void main() {
  // Mientras el Integrante 2 termina Drift + Firestore se usa el repository
  // en memoria. Solo hay que cambiar esta línea por la implementación real.
  final ProductRepository repository = InMemoryProductRepository();

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ProductRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo de productos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: ProductScreen(repository: repository),
    );
  }
}
