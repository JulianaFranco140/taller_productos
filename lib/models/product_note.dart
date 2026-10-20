// Información personal que el usuario guarda para un producto.
class ProductNote {
  final int productId;
  final String note;
  final int priority;
  final DateTime updatedAt;

  // true: el cambio todavía no llega a Firestore.
  final bool pendingSync;

  const ProductNote({
    required this.productId,
    required this.note,
    required this.priority,
    required this.updatedAt,
    this.pendingSync = true,
  });

  ProductNote copyWith({bool? pendingSync}) {
    return ProductNote(
      productId: productId,
      note: note,
      priority: priority,
      updatedAt: updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  factory ProductNote.fromJson(Map<String, dynamic> json) {
    return ProductNote(
      productId: json['productId'] as int,
      note: json['note'] as String,
      priority: json['priority'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // pendingSync no se envía: es un dato local, no del documento remoto.
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'note': note,
    'priority': priority,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
