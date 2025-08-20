import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final secureStorage = FlutterSecureStorage();

SimplePublicKey decodePublicKey(String key) =>
    SimplePublicKey(base64Decode(key), type: KeyPairType.x25519);

Future<void> generateAndSaveKeys(String userId) async {
  final algorithm = X25519();
  final keyPair = await algorithm.newKeyPair();

  final privateKey = await keyPair.extract();
  final privateKeyStr = base64Encode(privateKey.bytes);
  final publicKey = await keyPair.extractPublicKey();
  final publicKeyStr = base64Encode(publicKey.bytes);

  await secureStorage.write(key: 'private_key', value: privateKeyStr);
  await secureStorage.write(key: 'public_key', value: publicKeyStr);

  await Supabase.instance.client.from('user_keys').upsert({
    'user_id': userId,
    'public_key': publicKeyStr,
  }, onConflict: 'user_id');
}

Future<bool> checkKeyExist(String userId) async {
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
    return decodePublicKey(publicKey['public_key']);
  }
  throw Exception("Public key not found");
}

Future<SimpleKeyPair> getPrivateKeyOrGenerate(String userId) async {
  SimpleKeyPair privateKey;
  try {
    privateKey = await getMyKey();
  } catch (e) {
    await generateAndSaveKeys(userId);
    privateKey = await getMyKey();
  }
  return privateKey;
}

Future<SimpleKeyPair> getMyKey() async {
  final privateKeyString = await secureStorage.read(key: 'private_key');
  final publicKeyString = await secureStorage.read(key: 'public_key');
  if (privateKeyString != null && publicKeyString != null) {
    final privateKeyBytes = base64Decode(privateKeyString);
    final publicKeyBytes = base64Decode(publicKeyString);

    return SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );
  }
  throw Exception("Key not found");
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

  final aes = AesGcm.with256bits();
  final decryptedBytes = await aes.decrypt(secretBox, secretKey: sharedSecret);
  return decryptedBytes;
}
