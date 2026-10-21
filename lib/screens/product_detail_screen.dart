import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/product_note.dart';
import '../repository/product_repository.dart';
import '../utils/priority_rule.dart';
import '../widgets/product_card.dart';
import '../widgets/sync_status_chip.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ProductRepository repository;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.repository,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _noteController = TextEditingController();

  // Prioridad elegida en el formulario (null = ninguna).
  int? _priority;

  // Lo último que devolvió el repository; de aquí sale el estado de sync.
  ProductNote? _savedNote;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final saved = await widget.repository.getNote(widget.product.id);
    if (!mounted) return;
    setState(() {
      _savedNote = saved;
      if (saved != null) {
        _noteController.text = saved.note;
        _priority = saved.priority;
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    // Regla >= 2: si no se cumple, se informa y NO se llama al repository.
    final error = validatePriority(_priority);
    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.repository.saveNote(
        ProductNote(
          productId: widget.product.id,
          note: _noteController.text.trim(),
          priority: _priority!,
          updatedAt: DateTime.now(),
        ),
      );
      // Se vuelve a leer para mostrar el estado real guardado.
      final saved = await widget.repository.getNote(widget.product.id);
      if (!mounted) return;
      setState(() => _savedNote = saved);
      final remoteError = widget.repository.lastRemoteError;
      if (saved?.pendingSync == true && remoteError != null) {
        _showMessage('Guardado en el teléfono. Firebase falló: $remoteError');
      } else {
        _showMessage('Información guardada');
      }
    } catch (_) {
      _showMessage('No se pudo guardar la información');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 12),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final product = widget.product;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Card(
                        elevation: 3,
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ProductImage(url: product.imageUrl),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category_outlined, size: 18),
                        label: Text(product.category),
                        side: BorderSide.none,
                        backgroundColor: colors.secondaryContainer,
                      ),
                      Chip(
                        avatar: const Icon(Icons.sell_outlined, size: 18),
                        label: Text(formatPrice(product.price)),
                        side: BorderSide.none,
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Mi información',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!_loading) SyncStatusChip(note: _savedNote),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prioridad (1 a 5)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (var value = 1; value <= maxPriority; value++)
              ChoiceChip(
                label: Text('$value'),
                selected: _priority == value,
                onSelected: (_) => setState(() => _priority = value),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Solo se puede guardar con prioridad $minPriority o mayor.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nota personal',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
