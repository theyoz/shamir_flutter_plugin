import 'dart:convert';
import 'dart:typed_data';

import 'package:shamir_secret_plg/shamir_secret_plg.dart';

String _hex(Uint8List o) {
  return o.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

void main(List<String> arguments) async {
  String secret = "You will never find what I have hidden";
  IShamir shamir = ShamirClaude01();
  
  List<Uint8List>? shares = shamir.split(
      Uint8List.fromList(utf8.encode(secret)),
      totalShares: 5,
      threshold: 3);

  if (shares == null) {
    print("something gone wrong, you can try  to split again.");
  } else {
    for (int i = 0; i < shares.length; i++) {
      print("Share ${i + 1}: ${_hex(shares[i])}");
    }

    print("5 shares have been created, you need only 3 to reconstruct the secret. Let's take 1, 3, qnd 5");

    final selectedShares = [0, 2, 4].map((i) => shares[i]).toList();
    final bReconstructed = shamir.combine(selectedShares);
    final reconstructed = utf8.decode(bReconstructed);
    print("The secret was: $reconstructed");
  }

}
