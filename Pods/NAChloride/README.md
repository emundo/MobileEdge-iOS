NAChloride
===========

* SecretBox (via [libsodium](https://github.com/jedisct1/libsodium))
* Scrypt
* XSalsa20
* AES (256-CTR)
* TwoFish (CTR)
* HMAC (SHA1, SHA256, SHA512, SHA3)
* SHA3 (Keccak)
* HKDF (RFC 5849)
* Keychain Utils

See [gabriel/TPTripleSec](https://github.com/gabriel/TPTripleSec) for more usage examples of this library.

# Install

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects.

## Podfile

```ruby
platform :ios, '7.0'
pod "NAChloride"
```

# SecretBox (libsodium)

Secret-key authenticated encryption.

```objc
NSData *key = [NARandom randomData:NASecretBoxKeySize error:&error];
NSData *message = [@"This is a secret message" dataUsingEncoding:NSUTF8StringEncoding];

NASecretBox *secretBox = [[NASecretBox alloc] init];
NSData *encrypted = [secretBox encrypt:message key:key error:&error];
// If an error occurred encrypted will be nil and error set

NSData *decrypted = [secretBox decrypt:encrypted key:key error:&error];
```

# Scrypt

(via libsodium)

```objc
NSData *key = [@"toomanysecrets" dataUsingEncoding:NSUTF8StringEncoding];
NSData *salt = [NARandom randomData:48 error:&error]; // Random 48 bytes
NSData *data = [NAScrypt scrypt:key salt:salt N:32768U r:8 p:1 length:64 error:nil];
```

# XSalsa20

(via libsodium)

```objc
// Nonce should be 24 bytes
// Key should be 32 bytes
NAXSalsa20 *XSalsa20 = [[NAXSalsa20 alloc] init];
NSData *encrypted = [XSalsa20 encrypt:message nonce:nonce key:key error:&error];
```

# AES (256-CTR)

```objc
// Nonce should be 16 bytes
// Key should be 32 bytes
NAAES *AES = [[NAAES alloc] initWithAlgorithm:NAAESAlgorithm256CTR];
NSData *encrypted = [AES encrypt:message nonce:nonce key:key error:&error];
```

# TwoFish (CTR)

```objc
// Nonce should be 16 bytes
// Key should be 32 bytes
NATwoFish *twoFish = [[NATwoFish alloc] init];
NSData *encrypted = [twoFish encrypt:message nonce:nonce key:key error:&error];
```

# HMAC (SHA1, SHA256, SHA512, SHA3)

```objc
NSData *mac1 = [NAHMAC HMACForKey:key data:data algorithm:NAHMACAlgorithmSHA512];
NSData *mac2 = [NAHMAC HMACForKey:key data:data algorithm:NAHMACAlgorithmSHA3_512];
```

# Digest

```objc
NSData *SHA256 = [NADigest digestForData:data algorithm:NADigestAlgorithmSHA256];
NSData *SHA3_512 = [NADigest digestForData:data algorithm:NADigestAlgorithmSHA3_512];
```

# SHA3 (Keccak)

```objc
NSData *sha = [NASHA3 SHA3ForData:data digestBitLength:512];
```

# HKDF (RFC 5849)

```objc
NSData *key = [@"toomanysecrets" dataUsingEncoding:NSUTF8StringEncoding];
NSData *salt = [NARandom randomData:32 error:nil];

NSData *derivedKey = [NAHKDF HKDFForKey:key algorithm:NAHKDFAlgorithmSHA256 salt:salt info:nil length:64 error:nil];
```

# Keychain Utils

```objc
NSData *key = [NARandom randomData:32 error:&error];
[NAKeychain addSymmetricKey:key applicationLabel:@"NAChloride" tag:nil label:nil];
NSData *keyOut = [NAKeychain symmetricKeyWithApplicationLabel:@"NAChloride"];
```

# NSData Utils
```objc
NSData *data = [@"deadbeef" na_dataFromHexString];
[data na_hexString]; // @"deadbeef";
```

