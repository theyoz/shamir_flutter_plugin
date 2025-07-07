import 'dart:math' as math;
import 'dart:typed_data';

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

abstract class IShamir {
  List<Uint8List>? split(Uint8List secret,
      {required int totalShares, required int threshold});
  Uint8List combine(List<Uint8List> shares);
}

/// Implementation of Shamir's Secret Sharing for arbitrary data
class ShamirClaude01 implements IShamir {
  // Field size (a prime number) - using a Mersenne prime for efficiency
  final int _prime = 257; // 2^8 + 1, good for byte operations

  /// Split a secret into n shares where k are required to reconstruct
  @override
  List<Uint8List>? split(Uint8List secret,
      {required int totalShares, required int threshold}) {
    if (threshold > totalShares) {
      throw ArgumentError('Threshold cannot be greater than total shares');
    }

    if (threshold < 2) {
      throw ArgumentError('Threshold must be at least 2');
    }

    // Process the secret in blocks to handle arbitrary size
    final List<Uint8List> shares = List.generate(totalShares,
            (_) => Uint8List(secret.length + 1) // +1 for the x coordinate
    );

    // Initialize share x-coordinates (non-zero)
    for (int i = 0; i < totalShares; i++) {
      shares[i][0] = i + 1; // x-coordinate (1-indexed)
    }

    // Generate a cryptographically secure random object
    final secureRandom = math.Random.secure();

    // Process each byte of the secret
    for (int byteIndex = 0; byteIndex < secret.length; byteIndex++) {
      // For each byte, create a random polynomial
      // f(x) = secret + a1*x + a2*x^2 + ... + a(k-1)*x^(k-1) mod p
      final coefficients = List<int>.filled(threshold, 0);
      coefficients[0] = secret[byteIndex]; // constant term is the secret byte

      // Generate random coefficients for the polynomial
      for (int i = 1; i < threshold; i++) {
        coefficients[i] = secureRandom.nextInt(_prime - 1) + 1;
      }

      // Evaluate the polynomial for each share
      for (int i = 0; i < totalShares; i++) {
        int x = shares[i][0];
        int y = _evaluatePolynomial(coefficients, x);
        shares[i][byteIndex + 1] =
            y; // +1 because the first byte is the x-coordinate
      }
    }

    // test shares
    Uint8List testRes = combine(shares);
    return listEquals(secret, testRes) ? shares : null;
  }

  /// Combine k or more shares to reconstruct the original secret
  @override
  Uint8List combine(List<Uint8List> shares) {
    if (shares.isEmpty) {
      throw ArgumentError('No shares provided');
    }

    // All shares must have the same length
    final int shareLength = shares[0].length;
    for (final share in shares) {
      if (share.length != shareLength) {
        throw ArgumentError('All shares must have the same length');
      }
    }

    // The secret length is the share length minus 1 (for the x-coordinate)
    final secretLength = shareLength - 1;
    final result = Uint8List(secretLength);

    // Extract x-coordinates
    final List<int> xCoords = shares.map((share) => share[0]).toList();

    // Reconstruct each byte of the secret
    for (int byteIndex = 0; byteIndex < secretLength; byteIndex++) {
      // Extract y-coordinates for this byte
      final List<int> yCoords =
      shares.map((share) => share[byteIndex + 1]).toList();

      // Use Lagrange interpolation to find f(0)
      result[byteIndex] = _lagrangeInterpolation(xCoords, yCoords, 0);
    }

    return result;
  }

  /// Evaluate a polynomial at point x
  int _evaluatePolynomial(List<int> coefficients, int x) {
    int result = 0;
    int power = 1;

    for (final coefficient in coefficients) {
      result = (result + (coefficient * power) % _prime) % _prime;
      power = (power * x) % _prime;
    }

    return result;
  }

  /// Perform Lagrange interpolation to find y for a given x
  int _lagrangeInterpolation(List<int> xValues, List<int> yValues, int x) {
    int result = 0;

    for (int i = 0; i < xValues.length; i++) {
      int term = yValues[i];

      for (int j = 0; j < xValues.length; j++) {
        if (i != j) {
          // Calculate the Lagrange basis polynomial
          int numerator = (x - xValues[j]) % _prime;
          if (numerator < 0) numerator += _prime;

          int denominator = (xValues[i] - xValues[j]) % _prime;
          if (denominator < 0) denominator += _prime;

          // Find modular multiplicative inverse
          int invDenominator = _modInverse(denominator, _prime);

          term = (term * ((numerator * invDenominator) % _prime)) % _prime;
        }
      }

      result = (result + term) % _prime;
    }

    return result;
  }

  /// Calculate modular multiplicative inverse using Extended Euclidean Algorithm
  int _modInverse(int a, int m) {
    if (m == 1) return 0;

    int m0 = m;
    int y = 0, x = 1;

    while (a > 1) {
      int q = a ~/ m;
      int t = m;

      m = a % m;
      a = t;
      t = y;

      y = x - q * y;
      x = t;
    }

    if (x < 0) x += m0;

    return x;
  }
}

class ShamirSecretSharing {
  static final IShamir _instance = ShamirClaude01();

  static getInstance() {
    return _instance;
  }
}
