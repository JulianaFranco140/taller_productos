import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taller_productos/models/product.dart';
import 'package:taller_productos/repository/in_memory_product_repository.dart';
import 'package:taller_productos/screens/product_detail_screen.dart';

const product = Product(
  id: 7,
  name: 'Mouse Pulse',
  category: 'accesorios',
  price: 12,
  imageUrl: 'https://example.com/mouse.png',
);

Future<void> openDetail(
  WidgetTester tester,
  InMemoryProductRepository repo,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProductDetailScreen(product: product, repository: repo),
    ),
  );
  // Deja avanzar el reloj para que termine la lectura del repository.
  await tester.pump(const Duration(milliseconds: 10));
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pump(const Duration(milliseconds: 10));
}

void main() {
  testWidgets('sin registro muestra "Sin información guardada"', (
    tester,
  ) async {
    await openDetail(tester, InMemoryProductRepository(delay: Duration.zero));

    expect(find.text('Sin información guardada'), findsOneWidget);
  });

  testWidgets('prioridad 1 muestra el mensaje y no guarda', (tester) async {
    final repo = InMemoryProductRepository(delay: Duration.zero);
    await openDetail(tester, repo);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, '1'));
    await tapVisible(tester, find.text('Guardar'));

    expect(find.textContaining('mayor o igual a 2'), findsWidgets);
    expect(await repo.getNote(product.id), isNull);
    expect(find.text('Sin información guardada'), findsOneWidget);
  });

  testWidgets('prioridad válida guarda y queda Pendiente; luego Sincronizado', (
    tester,
  ) async {
    final repo = InMemoryProductRepository(delay: Duration.zero);
    await openDetail(tester, repo);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, '4'));
    await tester.enterText(find.byType(TextField), 'Comprar en diciembre');
    await tapVisible(tester, find.text('Guardar'));

    final saved = await repo.getNote(product.id);
    expect(saved!.priority, 4);
    expect(saved.note, 'Comprar en diciembre');
    expect(find.text('Pendiente'), findsOneWidget);

    // Al volver a abrir después de sincronizar, el estado viene del repository.
    await repo.syncPending();
    await tester.pumpWidget(const SizedBox());
    await openDetail(tester, repo);

    expect(find.text('Sincronizado'), findsOneWidget);
    expect(find.text('Comprar en diciembre'), findsOneWidget);
  });
}
