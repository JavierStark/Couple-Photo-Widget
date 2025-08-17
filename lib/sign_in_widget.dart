import 'package:couple_photo_widget/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      print("User is already signed in!");
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    Supabase.instance.client.auth
        .signInWithPassword(password: password, email: email)
        .then((response) {
          if (response.session == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error signing in: Invalid credentials'),
              ),
            );
          } else {
            print("User signed in successfully!");
            widget.onSignedIn.call();
          }
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing in: $error')));
        });
  }

  void _signUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    Supabase.instance.client.auth
        .signUp(password: password, email: email)
        .then((response) {
          if (response.user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error signing up: Could not create user'),
              ),
            );
          } else {
            widget.onSignedIn.call();
          }
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing up: $error')));
        });
  }
}
