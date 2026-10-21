import 'package:flutter/material.dart';

import '../models/product.dart';
import '../repository/product_repository.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  final ProductRepository repository;
  final ProductService? service;

  const ProductScreen({super.key, required this.repository, this.service});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ProductService _service;
  late Future<List<Product>> _futureProducts;

  // Evita lanzar dos sincronizaciones a la vez.
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ProductService();
    _futureProducts = _service.getProducts();
  }

  // Un Future nuevo hace que el FutureBuilder vuelva a mostrar la carga.
  void retryProducts() {
    setState(() {
      _futureProducts = _service.getProducts();
    });
  }

  // La pantalla solo pide sincronizar; la lógica vive en el repository.
  Future<void> syncPending() async {
    setState(() => _syncing = true);
    try {
      await widget.repository.syncPending();
      _showMessage('Pendientes sincronizados');
    } catch (error) {
      _showMessage('No se pudo sincronizar. Los cambios siguen pendientes. $error');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 12),
        ),
      );
  }

  void openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        // 1. Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error: se muestra el mensaje de ApiException y se permite reintentar.
        if (snapshot.hasError) {
          return _ErrorView(
            message: snapshot.error.toString(),
            onRetry: retryProducts,
          );
        }

        final products = snapshot.data ?? [];

        // 3. Sin datos
        if (products.isEmpty) {
          return const _EmptyView();
        }

        // 4. Datos disponibles
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length + 1,
          itemBuilder: (context, index) {
if (index == 0) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tenemos ${products.length} productos en nuestra tienda. Toca uno para ver su detalle',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _syncing ? null : syncPending,
          icon: _syncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync_alt_outlined),
          label: Text(_syncing ? 'Sincronizando...' : 'Sincronizar pendientes'),
        ),
      ],
    ),
  );
}
            final product = products[index - 1];
            return ProductCard(
              product: product,
              onTap: () => openProductDetail(product),
            );
          },
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar los productos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48),
            SizedBox(height: 16),
            Text(
              'Todavía no hay productos disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
