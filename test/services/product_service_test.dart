import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taller_productos/services/product_service.dart';

ProductService serviceWith(MockClient client) =>
    ProductService(client: client, timeout: const Duration(milliseconds: 200));

void main() {
  test('200 convierte la respuesta en una lista de Product', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'products': [
            {
              'id': 1,
              'title': 'Mouse',
              'category': 'accesorios',
              'price': 12,
              'thumbnail': 'https://example.com/mouse.png',
            },
          ],
        }),
        200,
      ),
    );

    final products = await serviceWith(client).getProducts();

    expect(products, hasLength(1));
    expect(products.first.name, 'Mouse');
    expect(products.first.price, 12.0);
  });

  test('200 con lista vacía devuelve una lista vacía', () async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode({'products': []}), 200),
    );

    expect(await serviceWith(client).getProducts(), isEmpty);
  });

  test('404 lanza ApiException', () async {
    final client = MockClient((_) async => http.Response('', 404));

    expect(
      serviceWith(client).getProducts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('404'),
        ),
      ),
    );
  });

  test('500 lanza ApiException de servidor', () async {
    final client = MockClient((_) async => http.Response('', 500));

    expect(
      serviceWith(client).getProducts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('servidor'),
        ),
      ),
    );
  });

  test('JSON inválido lanza ApiException', () async {
    final client = MockClient((_) async => http.Response('<html>', 200));

    expect(serviceWith(client).getProducts(), throwsA(isA<ApiException>()));
  });

  test('Formato inesperado lanza ApiException', () async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode([1, 2]), 200),
    );

    expect(serviceWith(client).getProducts(), throwsA(isA<ApiException>()));
  });

  test('Error de red lanza ApiException', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('sin red'),
    );

    expect(serviceWith(client).getProducts(), throwsA(isA<ApiException>()));
  });

  test('Timeout lanza ApiException', () async {
    final client = MockClient((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return http.Response(jsonEncode({'products': []}), 200);
    });

    expect(
      serviceWith(client).getProducts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('tardó'),
        ),
      ),
    );
  });
}
