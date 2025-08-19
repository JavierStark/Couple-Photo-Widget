import 'package:together_pic/image_picker_widget.dart';
import 'package:together_pic/match_widget.dart';
import 'package:together_pic/sign_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://gtlmhfprjmcajupwlegq.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0bG1oZnByam1jYWp1cHdsZWdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzNTg2MjksImV4cCI6MjA3MDkzNDYyOX0.7Z7jWBFGwT80FLv3G97iH1tAbPali9l4iqgHsNLwKI4';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const CouplePhotoApp());
}

class CouplePhotoApp extends StatelessWidget {
  const CouplePhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couple Photo Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const MyHomePage(title: 'Couple Photo Widget'),
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
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isSignedIn
                    ? (_isMatched
                          ? ImagePickerWidget()
                          : MatchWidget(onMatch: _handleMatch))
                    : SignInWidget(onSignedIn: _handleSignedIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
