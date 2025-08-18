import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final secureStorage = FlutterSecureStorage();

Future<void> generateAndSaveKeys(String userId) async {
  final algorithm = RsaPss(Sha256());
  final keyPair = await algorithm.newKeyPair();

  final privateKey = await keyPair.extract();
  final publicKey = await keyPair.extractPublicKey();

  // Save private key securely on device
  await secureStorage.write(key: 'private_key', value: privateKey.toString());

  // Save public key to Supabase table
  await Supabase.instance.client.from('user_keys').upsert({
    'user_id': userId,
    'public_key': publicKey.toString(),
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
