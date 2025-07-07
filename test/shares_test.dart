import 'package:shamir_secret_plg/src/shares.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  test('formatShareAsProperties <-> parseShareFromProperties roundtrip for v1', () {
    final original = ShamirShareV1()
      ..id = "abc123"
      ..filename = "secret.txt"
      ..minShares = 3
      ..share = Uint8List.fromList([1, 2, 3, 4, 5]);

    final text = serializeShares(original);
    final parsed = deserializeShares(text);

    expect(parsed, isA<ShamirShareV1>());
    final v1 = parsed as ShamirShareV1;

    expect(v1.id, equals(original.id));
    expect(v1.filename, equals(original.filename));
    expect(v1.minShares, equals(original.minShares));
    expect(v1.share, equals(original.share));
  });

  test('formatShareAsProperties failed <-> parseShareFromProperties roundtrip for v1', () {
    final original = ShamirShareV1()
      ..id = "abc123"
      ..filename = "secret.txt"
      ..minShares = 3
      ..share = Uint8List.fromList([1, 2, 3, 4, 5]);

    final text = serializeShares(original).replaceAll('Version=1', 'Version=2');
    expect(
          () => deserializeShares(text),
      throwsA(predicate((e) =>
      e is Exception && e.toString().contains('Unsupported share version'))),
    );
  });
}
