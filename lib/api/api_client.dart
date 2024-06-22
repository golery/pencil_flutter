import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: {
      "Authorization": "Bearer mock_token",
      "Accept": "application/json"
    });
  }

  Future<http.Response> postRequest(String endpoint, dynamic body) async {
    final bodyTxt = body == null ? null : jsonEncode(body);
    print('POST ${jsonEncode(bodyTxt)}');
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url,
        headers: {
          "Authorization": "Bearer mock_token",
          "Content-Type": "application/json"
        },
        body: bodyTxt);
  }

  Future<http.Response> deleteRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http
        .delete(url, headers: {"Authorization": "Bearer mock_token"});
  }
}
