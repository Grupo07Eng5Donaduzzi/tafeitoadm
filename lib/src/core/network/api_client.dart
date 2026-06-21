import 'dart:convert';

import 'package:http/http.dart' as http;

import '../result/result.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    http.Client? client,
    String? Function()? getToken,
  }) : baseUri = Uri.parse(baseUrl),
       _client = client ?? http.Client(),
       _getToken = getToken;

  final Uri baseUri;
  final http.Client _client;
  final String? Function()? _getToken;

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
    final normalizedBase = baseUri.toString().endsWith('/')
        ? baseUri
        : Uri.parse('${baseUri.toString()}/');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = query?.isNotEmpty == true
        ? normalizedBase.resolve(normalizedPath).replace(queryParameters: query)
        : normalizedBase.resolve(normalizedPath);

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final token = _getToken?.call();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final request = http.Request(method, uri)..headers.addAll(headers);

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await _client.send(request);
      final responseBody = await response.stream.bytesToString();
      final rawDecoded = responseBody.isEmpty ? null : jsonDecode(responseBody);
      final Map<String, dynamic> decoded;
      if (rawDecoded == null) {
        decoded = <String, dynamic>{};
      } else if (rawDecoded is List) {
        decoded = {'data': rawDecoded};
      } else if (rawDecoded is Map<String, dynamic>) {
        decoded = rawDecoded;
      } else {
        decoded = <String, dynamic>{};
      }

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
