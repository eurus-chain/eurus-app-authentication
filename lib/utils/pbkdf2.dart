import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

import 'address.dart';

class PBKDF2 {
  final int blockLength;
  final int iterationCount;
  final int desiredKeyLength;
  final String? pw;

  late PBKDF2KeyDerivator _derivator;
  late Uint8List _salt;

  PBKDF2({
    this.blockLength = 128,
    this.iterationCount = 2048,
    this.desiredKeyLength = 64,
    this.pw,
    String salt = 'mnemonic',
  }) {
    _salt = uint8ListFromList(utf8.encode('$salt${pw ?? ''}'));
    _derivator =
        new PBKDF2KeyDerivator(new HMac(new SHA512Digest(), blockLength))
          ..init(new Pbkdf2Parameters(_salt, iterationCount, desiredKeyLength));
  }

  Uint8List process(String mnemonic) {
    return _derivator.process(uint8ListFromList(mnemonic.codeUnits));
  }
}
