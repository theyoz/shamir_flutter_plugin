import 'dart:typed_data';
import 'package:shamir_secret_plg/src/shamir_algs.dart';
import 'package:test/test.dart';

void main() {
  final secretString = 'top_secret';
  final secret = Uint8List.fromList(secretString.codeUnits);

  const totalShares = 5;
  const threshold = 3;

  final implementations = <String, IShamir>{
    'ShamirClaude01': ShamirClaude01(),
    // Here we can add more algorithm to test
    //'ShamirAlternative': ShamirAlternative(), // Replace with actual class
  };

  implementations.forEach((name, shamir) {
    group('$name core logic', () {
      late List<Uint8List> shares;
      late Duration splitTime;
      late Duration combineAllTime;

      setUp(() {
        final stopwatch = Stopwatch()..start();
        List<Uint8List> result = shamir.split(secret, totalShares: totalShares, threshold: threshold);

        shares = result;

        stopwatch.stop();
        splitTime = stopwatch.elapsed;
      });

      test('All shares reconstruct the secret', () {
        final stopwatch = Stopwatch()..start();
        final combined = shamir.combine(shares);
        stopwatch.stop();
        combineAllTime = stopwatch.elapsed;

        print('[$name] Split took: ${splitTime.inMicroseconds}µs');
        print('[$name] Combine (all shares) took: ${combineAllTime.inMicroseconds}µs');

        expect(combined, equals(secret));
      });

      test('1 and 2 shares do not reconstruct correctly', () {
        for (int k = 1; k < threshold; k++) {
          final subsets = _combinations(shares, k);
          for (final subset in subsets) {
            final combined = shamir.combine(subset);
            expect(
              combined,
              isNot(equals(secret)),
              reason: 'Combining $k shares should NOT reconstruct the secret',
            );
          }
        }
      });

      test('3 or more shares reconstruct correctly', () {
        for (int k = threshold; k <= shares.length; k++) {
          final subsets = _combinations(shares, k);
          for (final subset in subsets) {
            final combined = shamir.combine(subset);
            expect(
              combined,
              equals(secret),
              reason: 'Combining $k shares SHOULD reconstruct the secret',
            );
          }
        }
      });
    });
  });
}

List<List<T>> _combinations<T>(List<T> input, int length) {
  List<List<T>> result = [];

  void combine(int start, List<T> current) {
    if (current.length == length) {
      result.add(List.from(current));
      return;
    }
    for (int i = start; i < input.length; i++) {
      current.add(input[i]);
      combine(i + 1, current);
      current.removeLast();
    }
  }

  combine(0, []);
  return result;
}
