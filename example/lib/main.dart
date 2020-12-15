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
  final TextEditingController mPhraseTextController = TextEditingController();

  String mnemonicPhrase = "";

  bool inputMPraseValid;

  String base58 = "";
  AddressPair addressPair;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Authentication Kit Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Generate Mnemonic Phrase',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
                children: [
                  Expanded(
                      key: Key('gen_mnemonic_result'),
                      flex: 2,
                      child: Text(mnemonicPhrase)),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        FlatButton(
                          key: Key('gen_mnemonic_btn'),
                          onPressed: () {
                            String mPhrase = _genMnemonic();
                            setState(() {
                              mnemonicPhrase = mPhrase;
                            });
                          },
                          child: Text(
                            'Generate 12 words',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        FlatButton(
                          key: Key('gen_mnemonic_24_btn'),
                          onPressed: () {
                            String mPhrase = _genMnemonic(strength: 256);
                            setState(() {
                              mnemonicPhrase = mPhrase;
                            });
                          },
                          child: Text(
                            'Generate 24 words',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        FlatButton(
                          key: Key('copy_mnemonic_btn'),
                          onPressed: () {
                            if (mnemonicPhrase != null) {
                              mPhraseTextController..text = mnemonicPhrase;
                              _resetValidFlag();
                            }
                          },
                          child: Text('Copy to Inputfield',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: mnemonicPhrase == null ||
                                          mnemonicPhrase == ''
                                      ? Colors.grey
                                      : Colors.black)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                'Import Mnemonic Phrase',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      key: Key('input_mnemonic_field'),
                      controller: mPhraseTextController,
                      onChanged: (e) {
                        _resetValidFlag();
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      key: Key('clear_btn'),
                      onPressed: () {
                        mPhraseTextController.clear();
                        _resetValidFlag();
                      },
                      child: Text(
                        'Clear',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                inputMPraseValid == null
                    ? ""
                    : inputMPraseValid == true
                        ? "Valid"
                        : "Invalid",
                style: TextStyle(
                  color: inputMPraseValid == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                key: Key('validate_result'),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      key: Key('validate_btn'),
                      onPressed: () {
                        String inputVal = mPhraseTextController.text;
                        bool isValid = _validateMnemonic(inputVal);
                        setState(() {
                          inputMPraseValid = isValid;
                        });
                      },
                      child: Text(
                        "Validate",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      key: Key('gen_base58_btn'),
                      onPressed: () {
                        if (inputMPraseValid) {
                          String b58 = _genBase58(mPhraseTextController.text);
                          setState(() {
                            base58 = b58;
                          });
                        }
                      },
                      child: Text(
                        'Generate Base58',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: inputMPraseValid == true
                                ? Colors.black
                                : Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      key: Key('gen_addressPair_btn'),
                      onPressed: () {
                        if (inputMPraseValid && base58 != '') {
                          AddressPair aPair = _genAddressPair(base58);
                          setState(() {
                            addressPair = aPair;
                          });
                        }
                      },
                      child: Text(
                        'Generate AddressPair',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: inputMPraseValid == true && base58 != ''
                                ? Colors.black
                                : Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
                children: [
                  Expanded(flex: 2, child: Text('Base58: ')),
                  Expanded(
                    flex: 5,
                    child: Text(base58 == null ? '' : base58, key: Key('base58_val'),),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
                children: [
                  Expanded(flex: 2, child: Text('Private Key: ')),
                  Expanded(
                    flex: 5,
                    child:
                        Text(addressPair == null ? '' : addressPair.privateKey, key: Key('privateKey_val'),),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
                children: [
                  Expanded(flex: 2, child: Text('Address: ')),
                  Expanded(
                    flex: 5,
                    child: Text(addressPair == null ? '' : addressPair.address, key: Key('address_val'),),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Generate 12 / 24 words mnemonic phrase base on strength
  /// 
  /// [strength] = 128 for 12 words
  /// [strength] = 256 for 24 words
  String _genMnemonic({int strength = 128}) {
    return MnemonicKit().genMnemonicPhrase(strength: strength);
  }

  /// Check if mnemonic phrase is valid
  bool _validateMnemonic(String mPhrase) {
    return MnemonicKit().validateMnemonic(mPhrase);
  }

  /// Generate Base58 from mnemonic phrase
  String _genBase58(String mPhrase) {
    return MnemonicKit().mnemonicToBase58(mPhrase);
  }

  /// Generate address and private key from Base58
  AddressPair _genAddressPair(String b58) {
    return MnemonicKit().genAddressPairFromBase58(b58);
  }

  /// Clear input field and generated values
  void _resetValidFlag() {
    setState(() {
      inputMPraseValid = null;
      base58 = '';
      addressPair = null;
    });
  }
}
