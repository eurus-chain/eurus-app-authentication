import 'dart:math';
import 'dart:typed_data';

import 'package:app_authentication_kit/utils/address.dart';
import 'package:app_authentication_kit/wordlist/english.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';

enum MnemonicError {
  INVALID_PHRASE,
  INVALID_ENTROPY,
  INVALID_MNEMONIC,
}

class Bip39 {
  static const int _SIZE_BYTE = 255;

  String entropyToMnemonic(String entropyString) {
    final entropy = HEX.decode(entropyString);
    if (entropy.length < 16) {
      throw ArgumentError(MnemonicError.INVALID_ENTROPY);
    }
    if (entropy.length > 32) {
      throw ArgumentError(MnemonicError.INVALID_ENTROPY);
    }
    if (entropy.length % 4 != 0) {
      throw ArgumentError(MnemonicError.INVALID_ENTROPY);
    }
    final entropyBits = _bytesToBinary(uint8ListFromList(entropy));
    final checksumBits = _deriveChecksumBits(uint8ListFromList(entropy));
    final bits = entropyBits + checksumBits;
    final regex =
        new RegExp(r".{1,11}", caseSensitive: false, multiLine: false);
    final chunks = regex
        .allMatches(bits)
        .map((match) => match.group(0))
        .toList(growable: false);
    String words =
        chunks.map((binary) => WORDLIST[_binaryToByte(binary ?? '')]).join(' ');
    return words;
  }

  String mnemonicToEntropy(String mnemonic) {
    var words = mnemonic.split(' ');
    if (words.length % 3 != 0) {
      throw new ArgumentError(MnemonicError.INVALID_MNEMONIC);
    }
    // convert word indices to 11 bit binary strings
    final bits = words.map((word) {
      final index = WORDLIST.indexOf(word);
      if (index == -1) {
        throw new ArgumentError(MnemonicError.INVALID_MNEMONIC);
      }
      return index.toRadixString(2).padLeft(11, '0');
    }).join('');
    // split the binary string into ENT/CS
    final dividerIndex = (bits.length / 33).floor() * 32;
    final entropyBits = bits.substring(0, dividerIndex);
    final checksumBits = bits.substring(dividerIndex);

    // calculate the checksum and compare
    final regex = RegExp(r".{1,8}");
    final entropyBytes = uint8ListFromList(regex
        .allMatches(entropyBits)
        .map((match) => _binaryToByte(match.group(0) ?? ''))
        .toList(growable: false));
    if (entropyBytes.length < 16) {
      throw StateError(MnemonicError.INVALID_ENTROPY.toString());
    }
    if (entropyBytes.length > 32) {
      throw StateError(MnemonicError.INVALID_ENTROPY.toString());
    }
    if (entropyBytes.length % 4 != 0) {
      throw StateError(MnemonicError.INVALID_ENTROPY.toString());
    }
    final newChecksum = _deriveChecksumBits(entropyBytes);
    if (newChecksum != checksumBits) {
      throw StateError(MnemonicError.INVALID_ENTROPY.toString());
    }
    return entropyBytes.map((byte) {
      return byte.toRadixString(16).padLeft(2, '0');
    }).join('');
  }

  Uint8List randomBytes(int size) {
    final rng = Random.secure();
    final bytes = Uint8List(size);
    for (var i = 0; i < size; i++) {
      bytes[i] = rng.nextInt(_SIZE_BYTE);
    }
    return bytes;
  }

  String _bytesToBinary(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
  }

  int _binaryToByte(String binary) {
    return int.parse(binary, radix: 2);
  }

  String _deriveChecksumBits(Uint8List entropy) {
    final ent = entropy.length * 8;
    final cs = ent ~/ 32;
    final hash = sha256.convert(entropy);
    return _bytesToBinary(uint8ListFromList(hash.bytes)).substring(0, cs);
  }
}
