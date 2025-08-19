import 'dart:convert';
import 'dart:typed_data';

import 'package:couple_photo_widget/utils.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:couple_photo_widget/crypto.dart';
import 'package:couple_photo_widget/match.dart';

const keyString = 'my32lengthsupersecretnooneknows1'; // 32 chars for AES-256
const ivString = '8bytesiv12345678'; // 16 chars for AES

//turn secret box into jsonobject and then into binary

Future<Uint8List?> compressImageToMemory(XFile file) async {
  return await FlutterImageCompress.compressWithFile(
    file.path,
    minWidth: 300,
    minHeight: 300,
    quality: 40,
    format: CompressFormat.jpeg,
  );
}

Future<void> uploadImage(XFile image) async {
  final client = Supabase.instance.client;
  final data = await compressImageToMemory(image);
  if (data == null) {
    throw Exception('Failed to compress image');
  }
  //generate random unique name
  final fileName =
      'img_${DateTime.now().millisecondsSinceEpoch}_${client.auth.currentUser?.id ?? ''}_${image.hashCode}.enc';

  SimpleKeyPair privateKey = await getPrivateKeyOrGenerate(
    client.auth.currentUser?.id ?? '',
  );

  final encrypted = await encryptImageWithSharedSecret(
    data,
    privateKey,
    await getPublicKey(await getSingleMatchUser()),
  );

  await client.storage
      .from('Images')
      .uploadBinary(fileName, await secretBoxToBinary(encrypted));

  await client
      .from('couples')
      .select('id, user1_email, user2_email')
      .or(
        'user1_email.eq.${client.auth.currentUser?.email},user2_email.eq.${client.auth.currentUser?.email}',
      )
      .eq('confirmed', true)
      .single()
      .then((value) async {
        final coupleId = value['id'] as String;

        final fieldName = value['user1_email'] == client.auth.currentUser?.email
            ? 'user1_photo'
            : 'user2_photo';

        await client.from('match_photos').upsert({
          'match_id': coupleId,
          fieldName: fileName,
        }, onConflict: 'match_id');
      });
}

Future<XFile> downloadImage(String imageName) async {
  final client = Supabase.instance.client;

  final response = await client.storage.from('Images').download(imageName);

  SimpleKeyPair privateKey = await getPrivateKeyOrGenerate(
    client.auth.currentUser?.id ?? '',
  );

  final imageData = await decryptImageWithSharedSecret(
    await binaryToSecretBox(response),
    privateKey,
    await getPublicKey(await getSingleMatchUser()),
  );

  return XFile.fromData(Uint8List.fromList(imageData), name: imageName);
}

Future<String?> getImageName() async {
  final client = Supabase.instance.client;

  final response = await client
      .from('match_photos')
      .select('user1_photo, user2_photo')
      .eq('match_id', await getSingleMatchId())
      .single();

  final whichUser = await client
      .from('couples')
      .select('user1_email, user2_email')
      .or(
        'user1_email.eq.${client.auth.currentUser?.email},user2_email.eq.${client.auth.currentUser?.email}',
      )
      .eq('confirmed', true)
      .single();

  final userEmail = client.auth.currentUser?.email;

  final photo = whichUser['user1_email'] == userEmail
      ? response['user2_photo']
      : response['user1_photo'];

  if (photo != null && photo is String && photo.isNotEmpty) {
    return photo;
  }
  return null;
}

Future<XFile?> getMatchPhoto() async {
  final imageName = await getImageName();
  if (imageName == null) {
    return null;
  }
  return downloadImage(imageName);
}
