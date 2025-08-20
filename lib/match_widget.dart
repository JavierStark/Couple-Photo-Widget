import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:together_pic/utils.dart';

class MatchWidget extends StatefulWidget {
  const MatchWidget({super.key, required this.onMatch});
  final void Function() onMatch;

  @override
  State<MatchWidget> createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  final TextEditingController _emailController = TextEditingController();
  final client = Supabase.instance.client;
  late final String myEmail;

  @override
  initState() {
    super.initState();

    myEmail = client.auth.currentUser!.email!;

    _checkConfirmedMatch();
  }

  void _checkConfirmedMatch() async {
    final confirmedRequest = await client
        .from('couples')
        .select('id')
        .or('user1_email.eq.$myEmail,user2_email.eq.$myEmail')
        .eq('confirmed', true)
        .maybeSingle();

    if (confirmedRequest != null) {
      snackBarMessage(context, 'You already have a confirmed match.');
      widget.onMatch();
    }
  }

  void _searchUser() async {
    final email = _emailController.text.trim();
    if (email == myEmail) {
      snackBarMessage(context, 'Cannot match with yourself');
      return;
    }

    // Check for any existing match or request in a single query
    final match = await client
        .from('couples')
        .select()
        .or(
          'user1_email.eq.$myEmail.and.user2_email.eq.$email,user1_email.eq.$email.and.user2_email.eq.$myEmail',
        )
        .maybeSingle();

    if (match != null) {
      if (match['confirmed'] == true) {
        snackBarMessage(context, 'You are already matched with this user.');
        widget.onMatch();
        return;
      }
      if (match['user1_email'] == email && match['user2_email'] == myEmail) {
        // Other user requested you, confirm match
        await client
            .from('couples')
            .update({'confirmed': true})
            .eq('id', match['id']);
        snackBarMessage(context, 'Match confirmed!');
        widget.onMatch();
        return;
      }
      if (match['user1_email'] == myEmail && match['user2_email'] == email) {
        snackBarMessage(context, 'You already requested this user.');
        return;
      }
    }

    // Add new request
    await client.from('couples').insert({
      'user1_email': myEmail,
      'user2_email': email,
      'confirmed': false,
    });
    snackBarMessage(context, 'Request sent!');

    // Poll for confirmation after delay
    Future.delayed(const Duration(seconds: 5), () async {
      final updatedMatch = await client
          .from('couples')
          .select()
          .or(
            'user1_email.eq.$myEmail.and.user2_email.eq.$email,user1_email.eq.$email.and.user2_email.eq.$myEmail',
          )
          .maybeSingle();
      if (updatedMatch != null && updatedMatch['confirmed'] == true) {
        snackBarMessage(context, 'Match confirmed!');
        widget.onMatch();
      } else {
        snackBarMessage(context, 'Still waiting for confirmation...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Enter email'),
        ),
        ElevatedButton(onPressed: _searchUser, child: const Text('Search')),
      ],
    );
  }
}
