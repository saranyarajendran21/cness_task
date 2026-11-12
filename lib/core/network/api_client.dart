import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/app_strings.dart';
import '../errors/app_exception.dart';
import 'network_info.dart';

/// Centralized HTTP client with connectivity check, auth header injection,
/// timeout handling, and envelope error parsing.
class ApiClient {
  ApiClient({
    required this._networkInfo,
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl =
            (baseUrl ?? ApiConstants.baseUrl).replaceAll(RegExp(r'/+$'), '');

  final NetworkInfo _networkInfo;
  final http.Client _client;
  final String _baseUrl;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final rawUri = Uri.parse('$_baseUrl$normalizedPath');
    if (queryParams == null || queryParams.isEmpty) {
      return rawUri;
    }

    final filteredParams = <String, String>{};
    queryParams.forEach((key, value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        filteredParams[key] = value.toString();
      }
    });

    return rawUri.replace(
      queryParameters: filteredParams.isEmpty ? null : filteredParams,
    );
  }

  Map<String, String> _buildHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    await _ensureConnected();
    final uri = _buildUri(path, queryParams);
    debugPrint('API GET -> $uri');

    return _execute(() async {
      final response = await _client
          .get(uri, headers: _buildHeaders(token: token))
          .timeout(ApiConstants.connectTimeout);
      return _handleResponse(response, uri);
    });
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    await _ensureConnected();
    final uri = _buildUri(path, queryParams);
    debugPrint('API POST -> $uri');

    return _execute(() async {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout);
      return _handleResponse(response, uri);
    });
  }

  Future<void> _ensureConnected() async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      debugPrint('API ERROR -> No internet connection');
      throw const NoInternetException();
    }
  }

  Future<Map<String, dynamic>> _execute(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on AppException {
      rethrow;
    } on SocketException {
      debugPrint('API ERROR -> SocketException (No internet)');
      throw const NoInternetException();
    } on TimeoutException {
      debugPrint('API ERROR -> RequestTimeoutException');
      throw const RequestTimeoutException();
    } on http.ClientException catch (e) {
      debugPrint('API ERROR -> ClientException: ${e.message}');
      throw ServerException(AppStrings.networkError(e.message));
    } on FormatException {
      debugPrint('API ERROR -> FormatException');
      throw const ParseException();
    } catch (e) {
      debugPrint('API ERROR -> Unexpected: $e');
      throw UnknownException(e.toString());
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response, Uri uri) {
    debugPrint(
      'API RESPONSE [${response.statusCode}] $uri: ${response.body}',
    );

    Map<String, dynamic> decoded;
    try {
      final raw = response.body.trim();
      if (raw.isEmpty) {
        decoded = <String, dynamic>{};
      } else {
        final json = jsonDecode(raw);
        if (json is Map<String, dynamic>) {
          decoded = json;
        } else {
          throw const ParseException();
        }
      }
    } on FormatException {
      if (response.statusCode >= 500) {
        throw ServerException(
          AppStrings.serverError(response.statusCode),
          statusCode: response.statusCode,
        );
      }
      throw const ParseException();
    }

    final statusCode = response.statusCode;
    final successObj = decoded['success'];
    final bool isEnvelopeSuccess =
        successObj is Map<String, dynamic> ? (successObj['status'] != false) : true;
    final errorObj = decoded['error'];

    if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException(
        _extractMessage(decoded) ?? AppStrings.unauthorizedFallback,
        statusCode,
      );
    }

    if (statusCode == 400 || statusCode == 422) {
      throw ValidationException(
        _extractMessage(decoded) ?? AppStrings.validationFallback,
        statusCode: statusCode,
        details: errorObj,
      );
    }

    if (statusCode >= 500) {
      throw ServerException(
        _extractMessage(decoded) ?? AppStrings.serverError(statusCode),
        statusCode: statusCode,
        details: errorObj,
      );
    }

    if (statusCode < 200 || statusCode >= 300 || !isEnvelopeSuccess || errorObj != null) {
      throw ServerException(
        _extractMessage(decoded) ?? AppStrings.requestFailed(statusCode),
        statusCode: statusCode,
        details: errorObj,
      );
    }

    return decoded;
  }

  String? _extractMessage(Map<String, dynamic> json) {
    final error = json['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }
    if (error is Map<String, dynamic>) {
      final msg = error['message'] ?? error['error'] ?? error['msg'];
      if (msg is String && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }

    final success = json['success'];
    if (success is Map<String, dynamic>) {
      final msg = success['message'];
      if (msg is String && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }

    final topMessage = json['message'];
    if (topMessage is String && topMessage.trim().isNotEmpty) {
      return topMessage.trim();
    }

    return null;
  }

  /// Unwraps the API's `{ data: { data: { ... } } }` or `{ data: { ... } }` envelope.
  static Map<String, dynamic> unwrapData(Map<String, dynamic> envelope) {
    final outer = envelope['data'];
    if (outer is Map<String, dynamic>) {
      final inner = outer['data'];
      if (inner is Map<String, dynamic>) {
        return inner;
      }
      return outer;
    }
    return envelope;
  }

  void dispose() {
    _client.close();
  }
}
