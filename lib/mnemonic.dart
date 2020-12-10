import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:app_authentication_kit/utils/address.dart';
import 'package:app_authentication_kit/utils/bip39.dart';
import 'package:app_authentication_kit/wordlist/english.dart';
import 'package:bip32/bip32.dart';
import 'package:crypto/crypto.dart';
import 'package:app_authentication_kit/utils/pbkdf2.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/digests/keccak.dart';
import 'package:pointycastle/digests/sha3.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

typedef Uint8List RandomBytes(int size);

class AddressPair {
  final String address;
  final String privateKey;

  AddressPair(this.address, this.privateKey);
}

class Mnemonic {
  /// Generate 12 words mnemonic phrase
  ///
  /// Return mnemonic phrase in [String]
  String genMnemonicPhrase({int strength = 128, RandomBytes randomBytes}) {
    assert(strength % 32 == 0);

    Uint8List entropy = randomBytes == null
        ? Bip39().randomBytes(strength ~/ 8)
        : randomBytes(strength ~/ 8);

    return Bip39().entropyToMnemonic(HEX.encode(entropy));
  }

  /// Validate mnemonic phrase
  ///
  /// Return [bool] indicates mnemonic phrase is valid or not
  bool validateMnemonic(String mnemonic) {
    try {
      Bip39().mnemonicToEntropy(mnemonic);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Generate Address and Private Key from mnemonic phrase
  ///
  /// Return [AddressPair] using mnemonic phrase
  String genAddressPair(String mneonicPhrase) {
    Uint8List seed = _mnemonicToSeed(mneonicPhrase);

    BIP32 node = BIP32.fromSeed(seed);
    final child = node.derivePath("m/44'/60'/0'/0/0");

    final a = KeccakDigest(256);

    final b = a.process(HEX.decode(HEX.encode(child.publicKey)));
    final c = b.sublist(b.length - 20, b.length);

    print("Public Key: ${HEX.encode(child.publicKey)}");
    print("Private Key: ${HEX.encode(child.privateKey)}");
    print("this is b $b - ${b.length}");
    print("this is c $c - ${c.length}");
    print("this is encoded ${HEX.encode(c)}");

    return node.toBase58();
  }

  String ggenAddressPair(String mneonicPhrase) {
    Uint8List seed = _mnemonicToSeed(mneonicPhrase);

    BIP32 node = BIP32.fromSeed(seed);
    final child = node.derivePath("m/44'/60'/0'/0/0");

    final address = EthAddress().ethereumAddressFromPublicKey(child.publicKey);

    print("mneonicPhrase $mneonicPhrase");
    // print("public key 028a8c59fa27d1e0f1643081ff80c3cf0392902acbf76ab0dc9c414b8d115b0ab3");
    print("public key ${HEX.encode(child.publicKey)}");

    return address;
  }

  /// Use mnemonic phrase to generate BIP39 seed
  ///
  /// [String] [mnemonic] provided to generate
  Uint8List _mnemonicToSeed(String mnemonic) {
    final pbkdf2 = new PBKDF2();
    return pbkdf2.process(mnemonic);
  }
}
