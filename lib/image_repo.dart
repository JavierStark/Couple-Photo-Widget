import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const keyString = 'my32lengthsupersecretnooneknows1'; // 32 chars for AES-256
const ivString = '8bytesiv12345678'; // 16 chars for AES

Future<void> uploadImage(XFile image) async {
  final client = Supabase.instance.client;

  print('\x1B[33m${client.auth.currentUser}\x1B[0m');

  final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.enc';

  var data = await image.readAsBytes();

  // Encrypt image bytes
  final key = encrypt.Key.fromUtf8(keyString);
  final iv = encrypt.IV.fromUtf8(ivString);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encryptBytes(data, iv: iv);

  await client.storage
      .from('Images')
      .uploadBinary(
        fileName,
        encrypted.bytes,
        fileOptions: const FileOptions(upsert: true),
      );

  final signedUrlResponse = await client.storage
      .from('Images')
      .createSignedUrl(fileName, 60 * 60 * 24); // 24 hours in seconds

  print('Image uploaded: $signedUrlResponse');
}

Future<XFile> downloadImage(String imageName) async {
  final client = Supabase.instance.client;

  final response = await client.storage.from('Images').download(imageName);
  final imageData = await decryptImage(response);

  return XFile.fromData(imageData);
}

Future<Uint8List> decryptImage(Uint8List encryptedBytes) async {
  final key = encrypt.Key.fromUtf8(keyString);
  final iv = encrypt.IV.fromUtf8(ivString);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final decrypted = encrypter.decryptBytes(
    encrypt.Encrypted(encryptedBytes),
    iv: iv,
  );
  return Uint8List.fromList(decrypted);
}
