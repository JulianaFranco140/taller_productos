import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'database/database_connection.dart';
import 'firebase_options.dart';
import 'repository/cloud_firestore.dart';
import 'repository/offline_first_product_repository.dart';
import 'repository/product_repository.dart';
import 'screens/product_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final ProductRepository repository = OfflineFirstProductRepository(
    database: openAppDatabase(),
    remote: FirestoreNoteStore(),
  );

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
