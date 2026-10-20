import 'package:flutter_test/flutter_test.dart';
import 'package:taller_productos/utils/priority_rule.dart';

void main() {
  test('sin prioridad no es válido', () {
    expect(validatePriority(null), isNotNull);
  });

  test('prioridad 1 no es válida', () {
    expect(validatePriority(1), contains('mayor o igual a 2'));
  });

  test('prioridades de 2 a 5 son válidas', () {
    for (final value in [2, 3, 4, 5]) {
      expect(validatePriority(value), isNull);
    }
  });
}
