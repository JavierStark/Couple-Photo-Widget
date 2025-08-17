import 'dart:io';

import 'package:couple_photo_widget/image_picker_widget.dart';
import 'package:couple_photo_widget/image_repo.dart';
import 'package:couple_photo_widget/match_widget.dart';
import 'package:couple_photo_widget/sign_in_widget.dart';
import 'package:couple_photo_widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://gtlmhfprjmcajupwlegq.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

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
  bool _isSignedIn = false;
  bool _isMatched = false;

  //callback signedin
  void _handleSignedIn() {
    setState(() {
      _isSignedIn = true;
    });
  }

  void _handleMatch() {
    setState(() {
      _isMatched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _isSignedIn
            ? (_isMatched
                  ? ImagePickerWidget()
                  : MatchWidget(onMatch: _handleMatch))
            : SignInWidget(onSignedIn: _handleSignedIn),
      ),
    );
  }
}
