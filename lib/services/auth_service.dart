import 'package:pocketbase/pocketbase.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8090';
  static final PocketBase client = PocketBase(baseUrl);

  AuthService({PocketBase? client}) : pb = client ?? AuthService.client;

  final PocketBase pb;

  Future<RecordAuth> login(String email, String password) {
    return pb.collection('users').authWithPassword(email, password);
  }

  Future<RecordAuth> register(
    String email,
    String password, {
    String? name,
  }) async {
    await pb.collection('users').create(
      body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );

    return login(email, password);
  }
}