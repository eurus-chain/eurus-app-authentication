# app_authentication_kit

app_authentication_kit is a plugin for application to preform a set of authentication functions e.g. generate mnemonic phrase, generate private key from mnemonic phrase.

## Usage
### Generate Mnemonic Phrase
```dart
import 'package:app_authentication_kit/app_authentication_kit.dart';

// Generate 12 words mnemonic phrase
// Return [String] contains 12 words
String mPharse = MnemonicKit().genMnemonicPhrase();

// Generate 24 words mnemonic phrase
// Return [String] contains 24 words
String mPharse = MnemonicKit().genMnemonicPhrase(strength: 256);
```
### Validate Mneonic Phraase
```dart
import 'package:app_authentication_kit/app_authentication_kit.dart';

// Validate mnemonic phrase
// Return [bool], [true] indicates valid, [false] indicates invalid
bool isValid = MnemonicKit().validateMnemonic(mPhrase);
```

### Import Mnemonic Phrase
```dart
import 'package:app_authentication_kit/app_authentication_kit.dart';

// Generate root key for application to store in local
// Uses this key to derivative Address and Private key
String base58 = MnemonicKit().mnemonicToBase58(mPhrase);

// Generate Address Pair
// [AddressPair] includes [String] [address],  [String] [publicKey] and [String] [privateKey]
AddressPair addressPair = MnemonicKit().genAddressPairFromBase58(base58);

// Or directly Generate Address Pair from Mnemonic Phrase
AddressPair addressPair = MnemonicKit().mnemonicPhraseToAddressPair(mPhrase);
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
