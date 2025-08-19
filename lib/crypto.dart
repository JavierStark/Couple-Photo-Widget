import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final secureStorage = FlutterSecureStorage();

SimplePublicKey decodePublicKey(String key) {
  final keyBytes = base64Decode(key);
  return SimplePublicKey(keyBytes, type: KeyPairType.x25519);
}

Future<void> generateAndSaveKeys(String userId) async {
  final algorithm = X25519();
  final keyPair = await algorithm.newKeyPair();

  final privateKey = await keyPair.extract();
  final privateKeyString = base64Encode(privateKey.bytes);
  final publicKey = await keyPair.extractPublicKey();
  final publicKeyStr = base64Encode(publicKey.bytes);

  await secureStorage.write(key: 'private_key', value: privateKeyString);

  await Supabase.instance.client.from('user_keys').upsert({
    'user_id': userId,
    'public_key': publicKeyStr,
  });
}

Future<bool> checkKeysExist(String userId) async {
  final publicKey = await Supabase.instance.client
      .from('user_keys')
      .select('public_key')
      .eq('user_id', userId)
      .maybeSingle();

  return publicKey != null;
}

Future<SimplePublicKey> getPublicKey(String userId) async {
  final publicKey = await Supabase.instance.client
      .from('user_keys')
      .select('public_key')
      .eq('user_id', userId)
      .maybeSingle();

  if (publicKey != null && publicKey['public_key'] != null) {
    return decodePublicKey(publicKey['public_key'] as String);
  }
  throw Exception("Public key not found");
}

Future<SimpleKeyPair> getPrivateKeyOrGenerate(String id) async {
  SimpleKeyPair privateKey;
  try {
    privateKey = await getPrivateKey();
  } catch (e) {
    await generateAndSaveKeys(id);
    privateKey = await getPrivateKey();
  }
  return privateKey;
}

Future<SimpleKeyPair> getPrivateKey() async {
  final privateKeyString = await secureStorage.read(key: 'private_key');
  if (privateKeyString != null) {
    final privateKeyBytes = base64Decode(privateKeyString);
    return SimpleKeyPairData(
      privateKeyBytes,
      type: KeyPairType.x25519,
      publicKey: SimplePublicKey(privateKeyBytes, type: KeyPairType.x25519),
    );
  }
  throw Exception("Private key not found");
}

Future<SecretBox> encryptImageWithSharedSecret(
  List<int> imageBytes,
  SimpleKeyPair myPrivateKey,
  SimplePublicKey theirPublicKey,
) async {
  final x25519 = X25519();
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: myPrivateKey,
    remotePublicKey: theirPublicKey,
  );

  final aes = AesGcm.with256bits();
  final nonce = aes.newNonce();
  final secretBox = await aes.encrypt(
    imageBytes,
    secretKey: sharedSecret,
    nonce: nonce,
  );

  //print mac and nonce
  print('MAC: ${secretBox.mac}');
  print('Nonce: ${secretBox.nonce}');
  return secretBox;
}

Future<List<int>> decryptImageWithSharedSecret(
  SecretBox secretBox,
  SimpleKeyPair myPrivateKey,
  SimplePublicKey theirPublicKey,
) async {
  final x25519 = X25519();
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: myPrivateKey,
    remotePublicKey: theirPublicKey,
  );

  //print mac and nonce
  print('MAC: ${secretBox.mac}');
  print('Nonce: ${secretBox.nonce}');

  final aes = AesGcm.with256bits();
  final decryptedBytes = await aes.decrypt(secretBox, secretKey: sharedSecret);
  return decryptedBytes;
}
