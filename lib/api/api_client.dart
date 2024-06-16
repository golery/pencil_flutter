import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: {"Authorization": "Bearer mock_token"});
  }

  Future<http.Response> postRequest(String endpoint, Object? body) async {
    print('POST ${jsonEncode(body)}');
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url,
        headers: {
          "Authorization": "Bearer mock_token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(body));
  }

  Future<http.Response> deleteRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http
        .delete(url, headers: {"Authorization": "Bearer mock_token"});
  }
}
