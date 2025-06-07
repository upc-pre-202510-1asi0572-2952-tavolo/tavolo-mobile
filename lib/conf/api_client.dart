import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final http.Client httpClient;
  final SecureStorage secureStorage;
  final String baseUrl;

  ApiClient({
    required this.httpClient,
    required this.secureStorage,
    required this.baseUrl,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await httpClient.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final headers = await _getHeaders();
    final response = await httpClient.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, {dynamic body}) async {
    final headers = await _getHeaders();
    final response = await httpClient.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await httpClient.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      final errorBody = json.decode(response.body);
      final errorMessage = errorBody['message'] ?? 'Unknown error occurred';
      throw ServerException(message: errorMessage);
    }
  }

  Future<dynamic> multipartPost(
      String endpoint, {
        required Map<String, String> fields,
        required Map<String, String> files,
      }) async {
    final headers = await _getHeaders();
    headers.remove('Content-Type');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );
    request.headers.addAll(headers);
    request.fields.addAll(fields);

    for (var entry in files.entries) {
      final file = await http.MultipartFile.fromPath(entry.key, entry.value);
      request.files.add(file);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }
}
