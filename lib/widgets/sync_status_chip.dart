import 'package:flutter/material.dart';

import '../models/product_note.dart';

// Muestra el estado según lo que devolvió el repository (no el formulario).
class SyncStatusChip extends StatelessWidget {
  final ProductNote? note;

  const SyncStatusChip({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final current = note;

    final (String label, IconData icon, Color background) = current == null
        ? (
            'Sin información guardada',
            Icons.info_outline,
            colors.surfaceContainerHighest,
          )
        : current.pendingSync
        ? ('Pendiente', Icons.schedule, colors.tertiaryContainer)
        : ('Sincronizado', Icons.cloud_done_outlined, colors.primaryContainer);

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      side: BorderSide.none,
      backgroundColor: background,
    );
  }
}
