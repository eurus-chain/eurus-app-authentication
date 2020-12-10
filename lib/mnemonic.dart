import 'dart:typed_data';
import 'package:app_authentication_kit/utils/address.dart';
import 'package:app_authentication_kit/utils/bip39.dart';
import 'package:bip32/bip32.dart';
import 'package:app_authentication_kit/utils/pbkdf2.dart';
import 'package:hex/hex.dart';

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
  /// Return [String] [address] using mnemonic phrase
  String genAddressFromMneonic(String mneonicPhrase) {
    Uint8List seed = _mnemonicToSeed(mneonicPhrase);

    BIP32 node = BIP32.fromSeed(seed);
    final child = node.derivePath("m/44'/60'/0'/0/0");

    final String address = EthAddress().ethereumAddressFromPublicKey(child.publicKey) ;

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
