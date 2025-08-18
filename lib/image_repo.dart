import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:couple_photo_widget/crypto.dart';
import 'package:couple_photo_widget/match.dart';

const keyString = 'my32lengthsupersecretnooneknows1'; // 32 chars for AES-256
const ivString = '8bytesiv12345678'; // 16 chars for AES

//turn secret box into jsonobject and then into binary
Future<Uint8List> secretBoxToBinary(SecretBox secretBox) async {
  final json = await secretBoxToJson(secretBox);
  return utf8.encode(json);
}

Future<String> secretBoxToJson(SecretBox secretBox) async {
  final json = {
    'cipherText': base64Encode(secretBox.cipherText),
    'nonce': base64Encode(secretBox.nonce),
    'mac': base64Encode(secretBox.mac.bytes),
  };
  return jsonEncode(json);
}

Future<SecretBox> jsonToSecretBox(String jsonString) {
  final json = jsonDecode(jsonString);
  return reconstructSecretBox(
    cipherTextBase64: json['cipherText'],
    nonceBase64: json['nonce'],
    macBase64: json['mac'],
  );
}

Future<SecretBox> reconstructSecretBox({
  required String cipherTextBase64,
  required String nonceBase64,
  required String macBase64,
}) async {
  final cipherText = base64Decode(cipherTextBase64);
  final nonce = base64Decode(nonceBase64);
  final mac = Mac(base64Decode(macBase64));

  return SecretBox(cipherText, nonce: nonce, mac: mac);
}

Future<SecretBox> binaryToSecretBox(Uint8List binary) async {
  final jsonString = utf8.decode(binary);
  return jsonToSecretBox(jsonString);
}

Future<void> uploadImage(XFile image) async {
  final client = Supabase.instance.client;

  final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.enc';

  var data = await image.readAsBytes();

  final encrypted = await encryptImageWithSharedSecret(
    data,
    await getPrivateKey(),
    await getPublicKey(await getSingleMatchUser()),
  );

  await client.storage
      .from('Images')
      .uploadBinary(fileName, await secretBoxToBinary(encrypted));
}

Future<XFile> downloadImage(String imageName) async {
  final client = Supabase.instance.client;

  final response = await client.storage.from('Images').download(imageName);

  final imageData = await decryptImageWithSharedSecret(
    await binaryToSecretBox(response),
    await getPrivateKey(),
    await getPublicKey(await getSingleMatchUser()),
  );

  return XFile.fromData(Uint8List.fromList(imageData), name: imageName);
}
