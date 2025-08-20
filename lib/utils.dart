import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

void snackBarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<Uint8List> secretBoxToBinary(SecretBox secretBox) async {
  final json = {
    'cipherText': base64Encode(secretBox.cipherText),
    'nonce': base64Encode(secretBox.nonce),
    'mac': base64Encode(secretBox.mac.bytes),
  };

  return Uint8List.fromList(utf8.encode(jsonEncode(json)));
}

//--------
Future<SecretBox> binaryToSecretBox(Uint8List binary) async {
  final json = jsonDecode(utf8.decode(binary));

  final cipherText = base64Decode(json['cipherText']);
  final nonce = base64Decode(json['nonce']);
  final mac = Mac(base64Decode(json['mac']));

  return SecretBox(cipherText, nonce: nonce, mac: mac);
}
