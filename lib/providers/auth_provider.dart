import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/errors/app_exception.dart';
import '../data/models/auth_model.dart';
import '../logic/auth_logic.dart';

/// MVVM ViewModel managing authentication state and login interactions.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required this._authLogic});

  final AuthLogic _authLogic;

  bool _isInitializing = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoginTab = true;
  bool _isGuestMode = false;

  String? _errorMessage;
  bool _isOfflineError = false;
  String? _savedEmail;
  String? _jwt;
  UserModel? _user;

  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoginTab => _isLoginTab;
  bool get isGuestMode => _isGuestMode;

  String? get errorMessage => _errorMessage;
  bool get isOfflineError => _isOfflineError;
  String? get savedEmail => _savedEmail;
  String? get jwt => _jwt;
  UserModel? get user => _user;
  bool get isAuthenticated => _jwt != null && _jwt!.isNotEmpty;

  /// Returns the logged-in JWT or the provided integration token.
  String get activeToken =>
      (_jwt != null && _jwt!.isNotEmpty) ? _jwt! : ApiConstants.defaultAuthToken;

  bool get hasAccessToken => activeToken.isNotEmpty;

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final session = await _authLogic.restoreSession();
      _rememberMe = session.rememberMe;
      _savedEmail = session.savedEmail;
      if (session.hasValidToken) {
        _jwt = session.jwt;
        _user = session.user;
      }
    } catch (_) {
      // Ignore corrupt local storage and default to login screen.
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setAuthTab(bool isLogin) {
    if (_isLoginTab == isLogin) return;
    _isLoginTab = isLogin;
    _errorMessage = null;
    _isOfflineError = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null || _isOfflineError) {
      _errorMessage = null;
      _isOfflineError = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isOfflineError = false;
    _isGuestMode = false;
    notifyListeners();

    try {
      final response = await _authLogic.login(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );
      _jwt = response.jwt;
      _user = response.user;
      _savedEmail = _rememberMe ? email.trim() : null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on NoInternetException catch (e) {
      _errorMessage = e.message;
      _isOfflineError = true;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = AppStrings.unexpectedLoginError;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void enterGuestMode() {
    _isGuestMode = true;
    _errorMessage = null;
    _isOfflineError = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authLogic.logout();
    _jwt = null;
    _user = null;
    _isGuestMode = false;
    _errorMessage = null;
    _isOfflineError = false;
    notifyListeners();
  }
}
