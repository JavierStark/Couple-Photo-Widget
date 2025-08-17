import 'dart:io';

import 'package:couple_photo_widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _image = image;
    });

    final dir = await getApplicationDocumentsDirectory();
    //change color of print
    print('\x1B[32mImage path: ${dir.path}\x1B[0m');
    final file = File('${dir.path}/widget.png');
    await file.writeAsBytes(await image.readAsBytes());
    print('\x1B[32mFile saved at: ${file.path}\x1B[0m');
    updateWidget(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
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
        ),
      ),
    );
  }
}
