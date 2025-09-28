import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Adjust baseUrl if your server runs on a different host/port
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost mapping

  final http.Client _http;

  ApiClient([http.Client? client]) : _http = client ?? http.Client();

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final uri = Uri.parse('$baseUrl$path');
    return _http.post(uri, headers: headers, body: body, encoding: encoding);
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return _http.get(uri, headers: headers);
  }

  Future<http.Response> put(String path, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final uri = Uri.parse('$baseUrl$path');
    return _http.put(uri, headers: headers, body: body, encoding: encoding);
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return _http.delete(uri, headers: headers);
  }
}
