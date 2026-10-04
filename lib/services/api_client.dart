import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = AppConfig.apiBaseUrl;

  static const _timeout = Duration(seconds: 10);
  static const _networkErrorMessage =
      'Tidak dapat terhubung ke server. Silakan periksa jaringan Anda.';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? body,
  }) async {
    final response = await _guard(
      () => http.post(
        Uri.parse('$baseUrl/$path'),
        headers: _headers(),
        body: body,
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _guard(
      () => http.get(Uri.parse('$baseUrl/$path'), headers: _headers()),
    );
    return _decode(response);
  }

  Future<http.Response> _guard(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on SocketException {
      throw ApiException(_networkErrorMessage);
    } on TimeoutException {
      throw ApiException(_networkErrorMessage);
    } on HttpException {
      throw ApiException(_networkErrorMessage);
    } on http.ClientException {
      throw ApiException(_networkErrorMessage);
    }
  }

  Map<String, String> _headers() {
    final headers = <String, String>{};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(_networkErrorMessage);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    throw ApiException(json['message'] as String? ?? 'Terjadi kesalahan');
  }
}
