import 'package:shamir_secret_plg/src/shamir_algs.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('listEquals', () {
    test('both null', () {
      expect(listEquals(null, null), isTrue);
    });

    test('one null, one not', () {
      expect(listEquals(null, []), isFalse);
      expect(listEquals([], null), isFalse);
    });

    test('empty lists', () {
      expect(listEquals([], []), isTrue);
    });

    test('same values', () {
      expect(listEquals([1, 2, 3], [1, 2, 3]), isTrue);
      expect(listEquals(['a', 'b'], ['a', 'b']), isTrue);
    });

    test('different values', () {
      expect(listEquals([1, 2, 3], [1, 2, 4]), isFalse);
      expect(listEquals(['a', 'b'], ['a', 'c']), isFalse);
    });

    test('different lengths', () {
      expect(listEquals([1, 2], [1, 2, 3]), isFalse);
    });

    test('same content but different reference', () {
      final a = Uint8List.fromList([10, 20, 30]);
      final b = Uint8List.fromList([10, 20, 30]);
      expect(listEquals(a, b), isTrue); // compares value not identity
    });

    test('modifying one list changes equality', () {
      final a = [1, 2, 3];
      final b = [1, 2, 3];
      expect(listEquals(a, b), isTrue);

      b[2] = 4;
      expect(listEquals(a, b), isFalse);
    });
  });
}
