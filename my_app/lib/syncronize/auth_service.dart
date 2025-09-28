import 'dart:convert';
import 'api_client.dart';
import 'models.dart';

class AuthService {
  final ApiClient _client;

  AuthService([ApiClient? client]) : _client = client ?? ApiClient();

  /// Register with JSON body {"username","email","password"}
  Future<TokenResponse> register(String username, String email, String password) async {
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    });
    final res = await _client.post('/auth/register', headers: headers, body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return TokenResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Register failed: ${res.statusCode} ${res.body}');
  }

  /// Login expects form data (OAuth2PasswordRequestForm)
  Future<TokenResponse> login(String username, String password) async {
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = 'username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}';
    final res = await _client.post('/auth/login', headers: headers, body: body);
    if (res.statusCode == 200) {
      return TokenResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Login failed: ${res.statusCode} ${res.body}');
  }
}
