import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> getSingleMatchUser() async {
  final client = Supabase.instance.client;
  final myEmail = client.auth.currentUser?.email;

  final response = await client
      .from('couples')
      .select('user1_email, user2_email')
      .or('user1_email.eq.$myEmail,user2_email.eq.$myEmail')
      .eq('confirmed', true)
      .single();

  return await client
      .from('user_emails')
      .select('id')
      .eq(
        'email',
        response['user1_email'] == myEmail
            ? response['user2_email']
            : response['user1_email'],
      )
      .maybeSingle()
      .then((value) => value?['id'] as String? ?? '');
}

Future<List<String>> getMatchedUsers() async {
  final client = Supabase.instance.client;
  final myEmail = client.auth.currentUser?.email;

  final response = await client
      .from('couples')
      .select('user1_email, user2_email')
      .or('user1_email.eq.$myEmail,user2_email.eq.$myEmail')
      .eq('confirmed', true);

  // get user id for each email
  final userIds = await Future.wait(
    response.map((email) async {
      final user = await client
          .from('user_emails')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      return user?['id'] as String?;
    }),
  );

  return userIds.whereType<String>().toList();
}

Future<String> getSingleMatchId() async {
  final client = Supabase.instance.client;
  final myEmail = client.auth.currentUser?.email;

  final response = await client
      .from('couples')
      .select('id')
      .or('user1_email.eq.$myEmail,user2_email.eq.$myEmail')
      .eq('confirmed', true)
      .single();

  return response['id'] as String;
}
