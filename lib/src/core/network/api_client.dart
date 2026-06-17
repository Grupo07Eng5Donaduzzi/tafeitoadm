import 'dart:convert';

import 'package:http/http.dart' as http;

import '../result/result.dart';

class ApiClient {
  ApiClient({required String baseUrl, http.Client? client})
    : baseUri = Uri.parse(baseUrl),
      _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  Future<Result<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? query,
  }) {
    return _send('GET', path, query: query);
  }

  Future<Result<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send('POST', path, body: body);
  }

  Future<Result<Map<String, dynamic>>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send('PATCH', path, body: body);
  }

  Future<Result<Map<String, dynamic>>> delete(String path) {
    return _send('DELETE', path);
  }

  Future<Result<Map<String, dynamic>>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = baseUri.replace(
      path: path,
      queryParameters: query?.isEmpty ?? true ? null : query,
    );

    try {
      final request = http.Request(method, uri)
        ..headers.addAll({
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        });

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await _client.send(request);
      final responseBody = await response.stream.bytesToString();
      final decoded = responseBody.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(decoded);
      }

      return Failure(
        AppFailure(
          message: decoded['message']?.toString() ?? 'Erro na requisição.',
          code: response.statusCode.toString(),
        ),
      );
    } on Object catch (error) {
      return Failure(AppFailure(message: error.toString()));
    }
  }

  void close() => _client.close();
}
