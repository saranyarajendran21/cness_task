import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/auth_model.dart';

/// Remote API service for authentication endpoints.
class AuthApi {
  const AuthApi({required this._apiClient});

  final ApiClient _apiClient;

  /// Calls `POST /api/auth/login` without an Authorization header.
  Future<LoginResponse> login(LoginRequest request) async {
    final envelope = await _apiClient.post(
      ApiConstants.loginPath,
      body: request.toJson(),
    );

    final innerData = ApiClient.unwrapData(envelope);
    final successObj = envelope['success'];
    final message = successObj is Map<String, dynamic>
        ? successObj['message']?.toString()
        : null;

    final response = LoginResponse.fromJson(innerData, message: message);
    if (response.jwt.isEmpty) {
      throw const ServerException('Authentication token missing in response.');
    }
    return response;
  }
}
