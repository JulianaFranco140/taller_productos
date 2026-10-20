import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taller_productos/repository/in_memory_product_repository.dart';
import 'package:taller_productos/screens/product_screen.dart';
import 'package:taller_productos/services/product_service.dart';

Widget appWith(MockClient client) => MaterialApp(
  home: ProductScreen(
    repository: InMemoryProductRepository(delay: Duration.zero),
    service: ProductService(client: client),
  ),
);

void main() {
  testWidgets('muestra carga y luego los productos', (tester) async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'products': [
            {
              'id': 1,
              'title': 'Teclado Nova',
              'category': 'accesorios',
              'price': 25,
              'thumbnail': 'https://example.com/t.png',
            },
          ],
        }),
        200,
      ),
    );

    await tester.pumpWidget(appWith(client));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    expect(find.text('Teclado Nova'), findsOneWidget);
  });

  testWidgets('muestra el estado vacío', (tester) async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode({'products': []}), 200),
    );

    await tester.pumpWidget(appWith(client));
    await tester.pump();

    expect(find.text('Todavía no hay productos disponibles'), findsOneWidget);
  });

  testWidgets('error muestra el mensaje y Reintentar vuelve a pedir', (
    tester,
  ) async {
    var calls = 0;
    // La demora imita la red: la respuesta llega después del siguiente frame.
    final client = MockClient((_) async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return http.Response('', 500);
    });

    await tester.pumpWidget(appWith(client));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Error en el servidor (500)'), findsOneWidget);
    expect(calls, 1);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, 2);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
