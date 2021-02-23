import "dart:convert";
import 'dart:ffi';
import "dart:typed_data";

import "package:convert/convert.dart" show hex;
// import 'package:pointycastle/digests/keccak.dart';
import 'package:pointycastle/digests/sha3.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';

// /web3dart-1.2.3/lib/src/crypto/keccac.dart
const int _shaBytes = 256 ~/ 8;
// keccak is implemented as sha3 digest in pointycastle, see
// https://github.com/PointyCastle/pointycastle/issues/128
final SHA3Digest sha3digest = SHA3Digest(_shaBytes * 8);

Uint8List keccak256(Uint8List input) {
  // return Uint8List(1);
  sha3digest.reset();
  return sha3digest.process(input);
}

Uint8List keccakUtf8(String input) {
  return keccak256(uint8ListFromList(utf8.encode(input)));
}

Uint8List keccakAscii(String input) {
  return keccak256(ascii.encode(input));
}

// /web3dart-1.2.3/lib/src/utils/typed_data.dart
Uint8List uint8ListFromList(List<int> data) {
  if (data is Uint8List) return data;

  return Uint8List.fromList(data);
}

class EthAddress {
  /// Derives an Ethereum address from a given public key.
  String ethereumAddressFromPublicKey(Uint8List publicKey, {addressType = 0}) {
    final decompressedPubKey = decompressPublicKey(publicKey);

    final hash = keccak256(decompressedPubKey.sublist(1));
    final address = hash.sublist(12, 32);

    if (addressType == 1) {
      return strip0x(hex.encode(address)).toUpperCase();
    }

    return checksumEthereumAddress(hex.encode(address));
  }

  /// Converts an Ethereum address to a checksummed address (EIP-55).
  String checksumEthereumAddress(String address) {
    if (!isValidFormat(address)) {
      throw ArgumentError.value(address, "address", "invalid address");
    }

    final addr = strip0x(address).toLowerCase();
    final hash = ascii.encode(hex.encode(
      keccak256(ascii.encode(addr)),
    ));

    var newAddr = "0x";

    for (var i = 0; i < addr.length; i++) {
      if (hash[i] >= 56) {
        newAddr += addr[i].toUpperCase();
      } else {
        newAddr += addr[i];
      }
    }

    return newAddr;
  }

  /// Returns whether a given Ethereum address is valid.
  bool isValidEthereumAddress(String address) {
    if (!isValidFormat(address)) {
      return false;
    }

    final addr = strip0x(address);
    // if all lowercase or all uppercase, as in checksum is not present
    if (RegExp(r"^[0-9a-f]{40}$").hasMatch(addr) ||
        RegExp(r"^[0-9A-F]{40}$").hasMatch(addr)) {
      return true;
    }

    String checksumAddress;
    try {
      checksumAddress = checksumEthereumAddress(address);
    } catch (err) {
      return false;
    }

    return addr == checksumAddress.substring(2);
  }

  /// Remove "0x" or "0X" from the start of an address
  String strip0x(String address) {
    if (address.startsWith("0x") || address.startsWith("0X")) {
      return address.substring(2);
    }
    return address;
  }

  /// Check if the address is valid using regular expression
  bool isValidFormat(String address) {
    return RegExp(r"^[0-9a-fA-F]{40}$").hasMatch(strip0x(address));
  }

  Uint8List decompressPublicKey(Uint8List publicKey) {
    final length = publicKey.length;
    final firstByte = publicKey[0];

    if ((length != 33 && length != 65) || firstByte < 2 || firstByte > 4) {
      throw ArgumentError.value(publicKey, "publicKey", "invalid public key");
    }

    final ecPublicKey = ECCurve_secp256k1().curve.decodePoint(publicKey);
    return ecPublicKey.getEncoded(false);
  }
}
