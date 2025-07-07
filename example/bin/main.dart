import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:shamir_secret_plg/shamir_secret_plg.dart';

String toHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  var s = ShamirSecretSharing.getInstance() as IShamir;
  String str = "Hello, world!";
  Uint8List bytes = Uint8List.fromList(utf8.encode(str));
  print("ORIGINAL: ${utf8.decode(bytes)}");
  print("");
  var split = s.split(bytes, totalShares: 5, threshold: 3)!;
  for (var i = 0; i < split.length; i++) {
    try {
      print('Element $i: ${toHex(split[i])}');
    } catch (e) {
      print('Element $i: [Invalid UTF-8]');
    }
  }

  var reconstruct = s.combine(split);
  print("");
  print("RECONSTRUCTED: ${utf8.decode(reconstruct)}");

  //runApp(const MyApp());
}
