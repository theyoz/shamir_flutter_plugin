import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:cryptography/cryptography.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import 'package:shamir_secret_plg/shamir_secret_plg.dart';
import 'cipher_utils.dart';
import 'package:path/path.dart' as p;

Future<File> _writeWithAutoPrefix({
  required File inputFile,
  required String targetFilename,
  required Uint8List data,
}) async {
  final dir = inputFile.parent;
  final base = p.basenameWithoutExtension(targetFilename);
  final ext = p.extension(targetFilename);

  for (int i = 0;; i++) {
    final prefix = i == 0 ? '' : '${i.toString().padLeft(2, '0')}_';
    final candidateName = '$prefix$base$ext';
    final fullPath = p.join(dir.path, candidateName);
    final candidateFile = File(fullPath);

    if (!await candidateFile.exists()) {
      await candidateFile.writeAsBytes(data);
      return candidateFile;
    }
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addCommand('reconstruct')
    ..addCommand('read_qr');

  final results = parser.parse(arguments);

  if (results['help'] || results.command == null) {
    printHelp();
    exit(0);
  }

  final cmd = results.command!;

  switch (cmd.name) {
    case 'reconstruct':
      if (cmd.arguments.length < 2) {
        print('Usage: reconstruct <input_file> <shares_part1> [part2] [...]');
        exit(1);
      }

      final inputFile = cmd.arguments[0];
      final sharePaths = cmd.arguments.sublist(1);
      final shares = <Uint8List>[];

      ShamirShare? firstShare;

      for (final path in sharePaths) {
        ShamirShare deserialized;

        final file = File(path);
        if (!file.existsSync()) {
          print('File not found: $path');
          exit(1);
        }

        if (path.endsWith('.jpg') || path.endsWith('.png')) {
          final bytes = decodeQrFromImage(file);
          if (bytes == null) {
            print('No QR found in $path');
            exit(1);
          }
          deserialized = ShareSerializer.deserializeShares(bytes);
        } else {
          deserialized = ShareSerializer.deserializeShares(file.readAsStringSync().trim());
        }

        firstShare ??= deserialized;

        if (deserialized is ShamirShareV1) {
          shares.add(deserialized.share);
        } else {
          print("Could not deserialize shares: $path");
        }
      }

      if (firstShare is ShamirShareV1) {
        IShamir shamir = ShamirClaude01();
        final combined = shamir.combine(shares);
        final data = await File(inputFile).readAsBytes();
        final decipheredData = await decryptFile(data, SecretKey(combined));
        final outputFile = await _writeWithAutoPrefix(inputFile: File(inputFile), targetFilename: firstShare.filename, data: decipheredData);
        print('Secret reconstructed and written to $outputFile');
      } else {
        print('Could not decrypt because shares file is unknown');
        exit(1);
      }

      break;

    case 'read_qr':
      if (cmd.arguments.isEmpty) {
        print('Usage: read_qr <file.jpg|png>');
        exit(1);
      }
      final file = File(cmd.arguments[0]);
      final result = decodeQrFromImage(file);
      if (result == null) {
        print('No QR code found');
        exit(1);
      }
      print('QR content: $result');
      break;

    default:
      printHelp();
  }
}

String? decodeQrFromImage(File file) {
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  final pixels = Int32List(image.width * image.height);
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final argb = (pixel.a.toInt() << 24) |
      (pixel.r.toInt() << 16) |
      (pixel.g.toInt() << 8)  |
      pixel.b.toInt();
      pixels[y * image.width + x] = argb;
    }
  }
  final source = RGBLuminanceSource(image.width, image.height, pixels);
  final bitmap = BinaryBitmap(HybridBinarizer(source));
  final reader = QRCodeReader();

  try {
    final result = reader.decode(bitmap);
    return result.text;
  } catch (_) {
    return null;
  }
}

void printHelp() {
  print('Shamir CLI Usage:');
  print('');
  print('  reconstruct <output_file> <part1> [part2] [...]');
  print('    Combine Shamir parts into a secret file.');
  print('    Parts can be base64 .txt or QR in .jpg/.png.');
  print('');
  print('  read_qr <file.jpg|png>');
  print('    Decode and print a QR code from an image.');
  print('');
}
