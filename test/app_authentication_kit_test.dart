import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_authentication_kit/app_authentication_kit.dart';

void main() {
  final String expectedMPharse =
      "bargain priority menu sunny depart decide join puppy maze course achieve deny";
  final String expectedBase58 =
      "xprv9s21ZrQH143K2fEtfpxEGppN5TaGvQ7exj9o2dNsLRS65ZKj3e2mguP25WRXGCwPNWiaGbsVPuZ5fpNCGcoMRPX1f3VEW7pMTNe8RaAPo9e";
  final String invalidMPharse =
      "bargain priority menu sunny depart decide joi puppy maze course achieve deny";
  final AddressPair address1 = AddressPair(
      '0x17D5440809303fDe49E0fb1ec2D3f93f4d3EFA12',
      '0xf72233af8564d26c7cc5a1a3eda8bf03edcb31eca9c62c9d18097cbcd0e6e4aa');
  final AddressPair address2 = AddressPair(
      '0x3d7fdeEb9AAA6A7Cf34dDCbae63Fc01fA5857ba9',
      '0x2b926ce06f57fe448d92d3f0bfd76ffdd14ee6b6aa6051f5818e024efc3114f5');
  final AddressPair address3 = AddressPair(
      '0x411F17f1cd87B9D9C8C9f56dd904ad8E049af3b1',
      '0x7b86fa33a7d9fd6588f6f7574f64e0248d9e07408ea712fa59ea559a307ed301');

  group('Generate mnemonic phrase', () {
    test('12 words Random mnemonic phrase', () {
      String mPharse = MnemonicKit().genMnemonicPhrase();
      // print("12 words: " + mPharse);
      expect(mPharse.split(' ').length, 12);
    });

    test('24 words Random mnemonic phrase', () {
      String mPharse = MnemonicKit().genMnemonicPhrase(strength: 256);
      // print("24 words: " + mPharse);
      expect(mPharse.split(' ').length, 24);
    });

    test('Fixed 12 words mnemonic phrase by fixed random bytes', () {
      String mPharse =
          MnemonicKit().genMnemonicPhrase(randomBytes: testingFixedBytes);
      // print("fixed words: " + mPharse);
      expect(mPharse, expectedMPharse);
    });
  });

  group('Validate mnemonic phrase', () {
    test('Valid mnemonic phrase', () {
      bool isValid = MnemonicKit().validateMnemonic(expectedMPharse);
      expect(isValid, true);
    });

    test('Invalid mnemonic phrase (incorrect word length)', () {
      bool isValid = MnemonicKit().validateMnemonic(expectedMPharse + " leaf");
      expect(isValid, false);
    });

    test('Invalid mnemonic phrase (incorrect word included)', () {
      bool isValid = MnemonicKit().validateMnemonic(invalidMPharse);
      expect(isValid, false);
    });
  });

  group('Import wallet', () {
    test('Generate Base58', () {
      String base58 = MnemonicKit().mnemonicToBase58(expectedMPharse);
      expect(base58, expectedBase58);
    });

    test('Import account with invalid mnemonic', () {
      String base58 = MnemonicKit().mnemonicToBase58(invalidMPharse);
      expect(base58, null);
    });

    test('Generate First Address Pair', () {
      AddressPair addressPair =
          MnemonicKit().genAddressPairFromBase58(expectedBase58);
      expect(addressPair.address, address1.address);
      expect(addressPair.privateKey, address1.privateKey);
    });

    test('Generate Second Address Pair', () {
      AddressPair addressPair =
          MnemonicKit().genAddressPairFromBase58(expectedBase58, accountIdx: 1);
      expect(addressPair.address, address2.address);
      expect(addressPair.privateKey, address2.privateKey);
    });
    test('Generate Third Address Pair', () {
      AddressPair addressPair =
          MnemonicKit().genAddressPairFromBase58(expectedBase58, accountIdx: 2);
      expect(addressPair.address, address3.address);
      expect(addressPair.privateKey, address3.privateKey);
    });
  });
}

Uint8List testingFixedBytes(int size) {
  Uint8List fixedBytes = Uint8List.fromList(
      [18, 181, 94, 44, 236, 179, 172, 113, 158, 13, 112, 137, 134, 40, 7, 29]);

  return fixedBytes;
}
