import 'dart:typed_data';
import 'package:app_authentication_kit/utils/address.dart';
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
    '17D5440809303fDe49E0fb1ec2D3f93f4d3EFA12',
    'f72233af8564d26c7cc5a1a3eda8bf03edcb31eca9c62c9d18097cbcd0e6e4aa',
    publicKey:
        '02340046704c14f3ad5b18006716e8a338988b904f5fd35cc66fc91e39395bb2cb',
  );
  final AddressPair address2 = AddressPair(
    '3d7fdeEb9AAA6A7Cf34dDCbae63Fc01fA5857ba9',
    '2b926ce06f57fe448d92d3f0bfd76ffdd14ee6b6aa6051f5818e024efc3114f5',
    publicKey:
        '034d0ba6902eeaa20a5e5eae06ff99a74af983e9f42d84ace8a515226767146060',
  );
  final AddressPair address3 = AddressPair(
    '411F17f1cd87B9D9C8C9f56dd904ad8E049af3b1',
    '7b86fa33a7d9fd6588f6f7574f64e0248d9e07408ea712fa59ea559a307ed301',
    publicKey:
        '03a76a9c3a19fd269f51b4a7ad77ef41d0dc81d7edb6e062331be750399ff1559e',
  );

  group('Generate mnemonic phrase', () {
    test('12 words Random mnemonic phrase', () {
      String mPharse = MnemonicKit().genMnemonicPhrase();
      expect(mPharse.split(' ').length, 12);
    });

    test('24 words Random mnemonic phrase', () {
      String mPharse = MnemonicKit().genMnemonicPhrase(strength: 256);
      expect(mPharse.split(' ').length, 24);
    });

    test('Fixed 12 words mnemonic phrase by fixed random bytes', () {
      String mPharse =
          MnemonicKit().genMnemonicPhrase(randomBytes: testingFixedBytes);
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
      String? base58 = MnemonicKit().mnemonicToBase58(expectedMPharse);
      expect(base58, expectedBase58);
    });

    test('Import account with invalid mnemonic', () {
      String? base58 = MnemonicKit().mnemonicToBase58(invalidMPharse);
      expect(base58, null);
    });

    test('Generate First Address Pair, address w/o 0x', () {
      AddressPair addressPair = MnemonicKit()
          .genAddressPairFromBase58(expectedBase58, addressType: 1);
      expect(addressPair.address, address1.address.toUpperCase());
      expect(addressPair.privateKey, address1.privateKey);
      expect(addressPair.publicKey, address1.publicKey);
    });

    test('Generate Second Address Pair, address w/o 0x', () {
      AddressPair addressPair = MnemonicKit().genAddressPairFromBase58(
          expectedBase58,
          accountIdx: 1,
          addressType: 1);
      expect(addressPair.address, address2.address.toUpperCase());
      expect(addressPair.privateKey, address2.privateKey);
      expect(addressPair.publicKey, address2.publicKey);
    });
    test('Generate Third Address Pair, address w/o 0x', () {
      AddressPair addressPair = MnemonicKit().genAddressPairFromBase58(
          expectedBase58,
          accountIdx: 2,
          addressType: 1);
      expect(addressPair.address, address3.address.toUpperCase());
      expect(addressPair.privateKey, address3.privateKey);
      expect(addressPair.publicKey, address3.publicKey);
    });

    test('Generate First Address Pair, address w 0x', () {
      AddressPair addressPair = MnemonicKit()
          .genAddressPairFromBase58(expectedBase58, addressType: 0);
      expect(addressPair.address, "0x${address1.address}");
      expect(addressPair.privateKey, address1.privateKey);
      expect(addressPair.publicKey, address1.publicKey);
    });

    test('Generate Second Address Pair, address w 0x', () {
      AddressPair addressPair = MnemonicKit().genAddressPairFromBase58(
          expectedBase58,
          accountIdx: 1,
          addressType: 0);
      expect(addressPair.address, "0x${address2.address}");
      expect(addressPair.privateKey, address2.privateKey);
      expect(addressPair.publicKey, address2.publicKey);
    });
    test('Generate Third Address Pair, address w 0x', () {
      AddressPair addressPair = MnemonicKit().genAddressPairFromBase58(
          expectedBase58,
          accountIdx: 2,
          addressType: 0);
      expect(addressPair.address, "0x${address3.address}");
      expect(addressPair.privateKey, address3.privateKey);
      expect(addressPair.publicKey, address3.publicKey);
    });

    test('Generate Address Pair from mnemonic', () {
      AddressPair addressPair = MnemonicKit()
          .mnemonicPhraseToAddressPair(expectedMPharse, addressType: 0);
      expect(addressPair.address, '0x${address1.address}');
      expect(addressPair.privateKey, address1.privateKey);
      expect(addressPair.publicKey, address1.publicKey);
    });
  });
}

Uint8List testingFixedBytes(int size) {
  Uint8List fixedBytes = uint8ListFromList(
      [18, 181, 94, 44, 236, 179, 172, 113, 158, 13, 112, 137, 134, 40, 7, 29]);

  return fixedBytes;
}
