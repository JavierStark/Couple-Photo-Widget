import 'package:couple_photo_widget/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:couple_photo_widget/utils.dart';
import 'package:couple_photo_widget/crypto.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key, required this.onSignedIn});

  final void Function() onSignedIn;

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //sign in auto if already session signed in
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      snackBarMessage(context, "User is already signed in!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSignedIn.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            controller: _passwordController,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _signIn, child: const Text('Sign In')),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
            ],
          ),
        ],
      ),
    );
  }

  void _signIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      snackBarMessage(context, "Please enter email and password");
      return;
    }

    Supabase.instance.client.auth
        .signInWithPassword(password: password, email: email)
        .then((response) {
          if (response.session == null) {
            snackBarMessage(context, "Error signing in: Invalid credentials");
          } else {
            snackBarMessage(context, "User signed in successfully!");
            checkKeysExist(response.user!.id).then((exists) {
              if (!exists) {
                generateAndSaveKeys(response.user!.id);
              }
            });
            widget.onSignedIn.call();
          }
        })
        .catchError((error) {
          snackBarMessage(context, "Error signing in: $error");
        });
  }

  void _signUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      snackBarMessage(context, "Please enter email and password");
      return;
    }

    Supabase.instance.client.auth
        .signUp(password: password, email: email)
        .then((response) {
          if (response.user == null) {
            snackBarMessage(context, "Error signing up: Could not create user");
          } else {
            snackBarMessage(context, "User signed up successfully!");
            generateAndSaveKeys(response.user!.id);
            widget.onSignedIn.call();
          }
        })
        .catchError((error) {
          snackBarMessage(context, "Error signing up: $error");
        });
  }
}
