import 'dart:convert';
import 'dart:typed_data';

String toHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

abstract class ShamirShare {}

class ShamirShareV1 implements ShamirShare {
  String id = "";
  String filename = "";
  int minShares = 0;
  Uint8List share = Uint8List(0);

  String getShareToHex() => toHex(share);
}

class ShareSerializer {
  static String serializeShares(ShamirShare share) {
    if (share is ShamirShareV1) {
      return "filename=${share.filename}\nID=${share.id}\nmin_shares=${share.minShares}\nVersion=1\nShare=${share.getShareToHex()}";
    }

    throw Exception("Unknown share type: ${share.runtimeType}");
  }

  static ShamirShare deserializeShares(String text) {
    final kv = Map.fromEntries(
      LineSplitter.split(text)
          .map((line) => line.trim())
          .where((line) => line.contains('='))
          .map((line) {
        final index = line.indexOf('=');
        final key = line.substring(0, index).trim();
        final value = line.substring(index + 1).trim();
        return MapEntry(key, value);
      }),
    );

    final version = kv['Version'];
    if (version == '1') {
      final filename = kv['filename'] ?? (throw Exception("Missing filename field"));
      final id = kv['ID'] ?? (throw Exception("Missing ID field"));
      final minShares = int.tryParse(kv['min_shares'] ?? '') ??
          (throw Exception("Invalid or missing min_shares"));
      final shareHex = kv['Share'] ?? (throw Exception("Missing Share field"));

      final shareBytes = Uint8List.fromList(
        List.generate(
          shareHex.length ~/ 2,
              (i) => int.parse(shareHex.substring(i * 2, i * 2 + 2), radix: 16),
        ),
      );

      return ShamirShareV1()
        ..id = id
        ..filename = filename
        ..minShares = minShares
        ..share = shareBytes;
    }

    throw Exception("Unsupported share version: $version");
  }
}
