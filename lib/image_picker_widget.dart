import 'dart:io';

import 'package:couple_photo_widget/image_repo.dart';
import 'package:couple_photo_widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'match.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _image = image;
    });

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/widget.png');
    await file.writeAsBytes(await image.readAsBytes());
    updateWidget(file.path);
    uploadImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () => _pickImage(),
          child: const Text('Pick Image'),
        ),
        const SizedBox(height: 20),
        _image != null
            ? Image.file(File(_image!.path), width: 200, height: 200)
            : const Text('No image selected'),
      ],
    );
  }
}
