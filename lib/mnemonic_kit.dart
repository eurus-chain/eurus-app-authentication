import 'dart:typed_data';
import 'package:app_authentication_kit/utils/address.dart';
import 'package:app_authentication_kit/utils/bip39.dart';
import 'package:bip32/bip32.dart';
import 'package:app_authentication_kit/utils/pbkdf2.dart';
import 'package:hex/hex.dart';

typedef Uint8List RandomBytes(int size);

class AddressPair {
  final String address;
  final String publicKey;
  final String privateKey;

  AddressPair(this.address, this.privateKey, {this.publicKey});
}

class MnemonicKit {
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

  /// Use mnemonic phrase to generate Base58
  ///
  /// return [BIP32] if mneomnic is valid
  /// return [null] if mnemonic is invalid
  BIP32 mnemonicToBIP32(String mnemonic) {
    if (!validateMnemonic(mnemonic)) return null;

    PBKDF2 pbkdf2 = new PBKDF2();
    Uint8List seed = pbkdf2.process(mnemonic);
    BIP32 node = BIP32.fromSeed(seed);

    return node;
  }

  /// Use mnemonic phrase to generate Base58
  ///
  /// return [String] [base58] if mneomnic is valid
  /// return [null] if mnemonic is invalid
  String mnemonicToBase58(String mnemonic) {
    return mnemonicToBIP32(mnemonic)?.toBase58();
  }

  /// Generate Address and Private Key from Base58
  ///
  /// Return [AddressPair]
  AddressPair genAddressPairFromBase58(
    String base58, {
    int accountIdx = 0,
    int addressType = 0,
  }) {
    BIP32 node = BIP32.fromBase58(base58);
    BIP32 child = node.derivePath("m/44'/60'/0'/0/$accountIdx");

    final String address = EthAddress().ethereumAddressFromPublicKey(
      child.publicKey,
      addressType: addressType,
    );

    return AddressPair(
      address,
      HEX.encode(child.privateKey),
      publicKey: HEX.encode(child.publicKey),
    );
  }

  /// Generate Address, Public key and Private Key from BIP32
  ///
  /// Return [AddressPair]
  AddressPair genAddressPairFromBIP32(
    BIP32 node, {
    int accountIdx = 0,
    int addressType = 0,
  }) {
    BIP32 child = node.derivePath("m/44'/60'/0'/0/$accountIdx");

    final String address = EthAddress().ethereumAddressFromPublicKey(
      child.publicKey,
      addressType: addressType,
    );

    return AddressPair(
      address,
      HEX.encode(child.privateKey),
      publicKey: HEX.encode(child.publicKey),
    );
  }

  /// Generate Address, Public key and Private Key from Mnemonic Phrase
  ///
  /// Return [AddressPair]
  AddressPair mnemonicPhraseToAddressPair(
    String mnemonic, {
    int accountIdx = 0,
    int addressType = 0,
  }) {
    return genAddressPairFromBIP32(
      mnemonicToBIP32(mnemonic),
      accountIdx: accountIdx,
      addressType: addressType,
    );
  }
}
