import 'dart:typed_data';

import 'package:app_authentication_kit/mnemonic_kit.dart';
import 'package:app_authentication_kit/utils/pbkdf2.dart';
import 'package:flutter/material.dart';
import 'package:app_authentication_kit/app_authentication_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String hexString = '';
  MnemonicKit mmKit;

  @override
  void initState() {
    super.initState();
    setState(() {
      mmKit = MnemonicKit();
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            // child: Text('Running on: $_platformVersion\n'),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Running on: $_platformVersion\n'),
            Text(tryHex()),
            FlatButton(
              onPressed: testGenprvKey,
              child: Text("gen private key"),
            )
          ],
        )),
      ),
    );
  }

  String tryHex() {
    PBKDF2 pbkdf2 = new PBKDF2();
    Uint8List seed = pbkdf2.process(
        'replace combine rich session track tape elder nurse news know deliver super sorry awesome kitten cargo below blade cash already artist velvet amount mesh');

    String dummyString = seed.map((byte) {
      return byte.toRadixString(16).padLeft(2, '0');
    }).join('');

    return dummyString;
  }

  void tryMemonic() {
    String dummy = MnemonicKit().genMnemonicPhrase();

    print(dummy);
  }

  void testGenprvKey() {
    String base58 = MnemonicKit().mnemonicToBase58(
        'pipe isolate pyramid toddler magic whisper fortune rely abstract relax manual surface');
    AddressPair a = MnemonicKit().genAddressPairFromBase58(base58);
    print("Print Result ${a.address} - ${a.privateKey}");
  }
}
