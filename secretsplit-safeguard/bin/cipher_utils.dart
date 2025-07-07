import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';

import 'package:cryptography/cryptography.dart';
import 'package:shamir_secret_plg/shamir_secret_plg.dart';

const String headerString = "NO_EXECUTABLE";

Future<Uint8List> decryptFile(Uint8List encryptedData, SecretKey key) async {
  final headerBytes = utf8.encode(headerString);
  final headerLength = headerBytes.length;

  // Validate that the header matches
  if (encryptedData.length < headerLength) {
    throw Exception("Encrypted data too short to contain header");
  }

  final actualHeader = encryptedData.sublist(0, headerLength);
  if (!const ListEquality().equals(actualHeader, headerBytes)) {
    throw Exception("Missing or incorrect NO_EXECUTABLE header");
  }

  // Remove the header
  encryptedData = encryptedData.sublist(headerLength);
  // Define the algorithm using AES-CBC (no MAC)
  final algorithm = AesCbc.with128bits(macAlgorithm: MacAlgorithm.empty);

  // Extract IV from the beginning of the encrypted data (first 16 bytes)
  final iv = encryptedData.sublist(0, 16);
  print("Decrypt IV: ${toHex(Uint8List.fromList(iv))}");
  print(
      "Decrypt key: ${toHex(Uint8List.fromList(await key.extractBytes()))}");

  // The rest is the ciphertext
  final cipherText = encryptedData.sublist(16);

  // Create a dummy MAC since Mac is required but unused (for compatibility)
  final dummyMac = Mac(Uint8List(0)); // Empty MAC bytes

  // Create the SecretBox with ciphertext, nonce (IV), and dummy MAC
  final secretBox = SecretBox(cipherText, nonce: iv, mac: dummyMac);
  print('D Cipher length: ${secretBox.cipherText.length}');
  print('D MAC: ${secretBox.mac.bytes}');
  print('D Nonce: ${secretBox.nonce}');

  // Decrypt the file
  final decrypted = await algorithm.decrypt(secretBox, secretKey: key);
  return Uint8List.fromList(decrypted);
}
