## 0.0.5
+ ### Added [addressType] for having different address format
    + addressType = 0, Address will start with [0x] and will have checksum
    + addressType = 1, Address will not start with [0x] and will not have checksum
## 0.0.4
+ ### Added public key into AddressPair
+ ### Added Functions
    + mnemonicToBIP32(String mnemonic)
        + Generate BIP32 from mnemonic
    + mnemonicPhraseToAddressPair(String mnemonic)
        + Generate Address Pair form mnemonic phrase

## 0.0.3
* Dependency bug quick fix

## 0.0.2 
* Files formatted according to dartfmt
## 0.0.1
* Initialize Package