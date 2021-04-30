import 'dart:typed_data';
import 'package:app_authentication_kit/utils/address.dart';
import 'package:app_authentication_kit/utils/bip39.dart';
import 'package:bip32/bip32.dart';
import 'package:app_authentication_kit/utils/pbkdf2.dart';
import 'package:hex/hex.dart';

typedef Uint8List RandomBytes(int size);

class AddressPair {
  final String address;
  String get publicKey => _publicKey ?? HEX.encode(BIP32.fromPrivateKey(HEX.decode(privateKey), null).publicKey);
  final String _publicKey;
  final String privateKey;

  AddressPair(this.address, this.privateKey, {publicKey}) : this._publicKey = publicKey;
}

class MnemonicKit {
  /// Generate 12 words mnemonic phrase
  ///
  /// Return mnemonic phrase in [String]
  String genMnemonicPhrase({int strength = 128, RandomBytes randomBytes}) {
    assert(strength % 32 == 0);

    Uint8List entropy = randomBytes == null ? Bip39().randomBytes(strength ~/ 8) : randomBytes(strength ~/ 8);

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
  BIP32 mnemonicToBIP32(String mnemonic, {String pw}) {
    if (!validateMnemonic(mnemonic)) return null;

    PBKDF2 pbkdf2 = new PBKDF2(pw: pw);
    Uint8List seed = pbkdf2.process(mnemonic);
    BIP32 node = BIP32.fromSeed(seed);

    return node;
  }

  /// Use mnemonic phrase to generate Base58
  ///
  /// return [String] [base58] if mneomnic is valid
  /// return [null] if mnemonic is invalid
  String mnemonicToBase58(String mnemonic, {String pw}) {
    return mnemonicToBIP32(mnemonic, pw: pw)?.toBase58();
  }

  /// Generate Address and Private Key from Base58
  ///
  /// Return [AddressPair]
  AddressPair genAddressPairFromBase58(
    String base58, {
    int account = 0,
    int change = 0,
    int accountIdx = 0,
    int addressType = 0,
  }) {
    BIP32 node = BIP32.fromBase58(base58);
    BIP32 child = node.derivePath("m/44'/60'/$account'/$change/$accountIdx");

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
    int account = 0,
    int change = 0,
    int accountIdx = 0,
    int addressType = 0,
  }) {
    print("m/44'/60'/$account'/$change/$accountIdx");
    BIP32 child = node.derivePath("m/44'/60'/$account'/$change/$accountIdx");

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
    int account = 0,
    int change = 0,
    int accountIdx = 0,
    int addressType = 0,
    String pw,
  }) {
    return genAddressPairFromBIP32(
      mnemonicToBIP32(mnemonic, pw: pw),
      account: account,
      change: change,
      accountIdx: accountIdx,
      addressType: addressType,
    );
  }
}
