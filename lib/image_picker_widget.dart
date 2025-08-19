import 'dart:io';

import 'package:couple_photo_widget/crypto.dart';
import 'package:couple_photo_widget/image_repo.dart';
import 'package:couple_photo_widget/utils.dart';
import 'package:couple_photo_widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _sendingImage;
  XFile? _receivedImage;
  bool _isPickingLoading = false;
  bool _isReceivingLoading = false;

  Future<void> _pickImage() async {
    setState(() {
      _isPickingLoading = true;
    });
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _sendingImage = image;
      });
      await uploadImage(image);
    }
    setState(() {
      _isPickingLoading = false;
    });
  }

  Future<void> _receiveImageAndUpdateWidget() async {
    setState(() {
      _isReceivingLoading = true;
    });
    XFile? image = await getMatchPhoto();

    if (image == null) {
      setState(() {
        _isReceivingLoading = false;
      });
      snackBarMessage(context, 'No image found for the current match');
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/widget.png');
    await file.writeAsBytes(await image.readAsBytes());
    await updateWidget(file.path);
    snackBarMessage(context, 'Widget updated with new image');

    setState(() {
      _receivedImage = image;
      _isReceivingLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: _isPickingLoading ? null : _pickImage,
          child: const Text('Pick Image'),
        ),
        if (_isPickingLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        const SizedBox(height: 20),
        _sendingImage != null
            ? Image.file(File(_sendingImage!.path), width: 200, height: 200)
            : const SizedBox(width: 200, height: 200),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isReceivingLoading ? null : _receiveImageAndUpdateWidget,
          child: const Text('Update Widget / Receive Image'),
        ),
        if (_isReceivingLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        _receivedImage != null
            ? Image.file(File(_receivedImage!.path), width: 200, height: 200)
            : const SizedBox(width: 200, height: 200),
      ],
    );
  }
}
