import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

// Error con un mensaje que la pantalla puede mostrar tal cual.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductService {
  static const defaultUrl =
      'https://dummyjson.com/products?limit=30&select=title,category,price,thumbnail';

  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  // El cliente se puede inyectar para probar el servicio sin internet.
  ProductService({
    this.baseUrl = defaultUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.get(Uri.parse(baseUrl)).timeout(timeout);

      if (response.statusCode != 200) {
        throw ApiException(_messageForStatus(response.statusCode));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['products'] is! List) {
        throw const ApiException(
          'La respuesta del servidor no tiene el formato esperado',
        );
      }

      final List<dynamic> data = decoded['products'];
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder');
    } on SocketException {
      throw const ApiException('Sin conexión a internet');
    } on http.ClientException {
      throw const ApiException('No se pudo completar la petición');
    } on FormatException {
      throw const ApiException(
        'La respuesta del servidor no es un JSON válido',
      );
    } on TypeError {
      // Un producto llegó sin un campo obligatorio o con otro tipo.
      throw const ApiException(
        'La respuesta del servidor no tiene el formato esperado',
      );
    }
  }

  String _messageForStatus(int statusCode) {
    if (statusCode == 404) return 'No se encontraron los productos (404)';
    if (statusCode >= 500) return 'Error en el servidor ($statusCode)';
    return 'Error HTTP $statusCode';
  }
}
