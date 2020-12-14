import 'package:app_authentication_kit/mnemonic_kit.dart';
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
            FlatButton(
              onPressed: testGenprvKey,
              child: Text("gen private key"),
            )
          ],
        )),
      ),
    );
  }

  void testGenprvKey() {
    String base58 = MnemonicKit().mnemonicToBase58(
        'pipe isolate pyramid toddler magic whisper fortune rely abstract relax manual surface');
    AddressPair a = MnemonicKit().genAddressPairFromBase58(base58);
    print("Print Result ${a.address} - ${a.privateKey}");
  }
}
