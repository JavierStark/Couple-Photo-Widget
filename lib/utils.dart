import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

void snackBarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

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
