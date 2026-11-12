import '../core/errors/app_exception.dart';
import '../core/network/network_info.dart';
import '../core/storage/token_storage.dart';
import '../data/api/auth_api.dart';
import '../data/models/auth_model.dart';
import 'validators.dart';

/// Restored session snapshot from local storage.
class SavedAuthSession {
  const SavedAuthSession({
    required this.jwt,
    required this.user,
    required this.rememberMe,
    this.savedEmail,
  });

  final String? jwt;
  final UserModel? user;
  final bool rememberMe;
  final String? savedEmail;

  bool get hasValidToken => jwt != null && jwt!.isNotEmpty;
}

/// Business logic layer for authentication and session management.
class AuthLogic {
  const AuthLogic({
    required this._authApi,
    required this._tokenStorage,
    required this._networkInfo,
  });

  final AuthApi _authApi;
  final TokenStorage _tokenStorage;
  final NetworkInfo _networkInfo;

  Future<bool> hasInternet() => _networkInfo.isConnected;

  Future<SavedAuthSession> restoreSession() async {
    final jwt = await _tokenStorage.getJwt();
    final user = await _tokenStorage.getUser();
    final rememberMe = await _tokenStorage.getRememberMe();
    final savedEmail = await _tokenStorage.getSavedEmail();
    return SavedAuthSession(
      jwt: jwt,
      user: user,
      rememberMe: rememberMe,
      savedEmail: savedEmail,
    );
  }

  /// Validates credentials, checks connectivity, performs login, and persists tokens.
  Future<LoginResponse> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(emailError);
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(passwordError);
    }

    final connected = await _networkInfo.isConnected;
    if (!connected) {
      throw const NoInternetException();
    }

    final response = await _authApi.login(
      LoginRequest(email: email.trim(), password: password),
    );

    await _tokenStorage.saveSession(
      jwt: response.jwt,
      refreshToken: response.refreshToken,
      user: response.user,
      rememberMe: rememberMe,
      email: email.trim(),
    );

    return response;
  }

  Future<void> logout() => _tokenStorage.clearSession();
}
