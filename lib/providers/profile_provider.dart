import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/app_strings.dart';
import '../core/errors/app_exception.dart';
import '../data/models/profile_model.dart';
import '../logic/profile_logic.dart';

/// MVVM ViewModel managing the own Profile screen state.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required this._profileLogic}) {
    _connectivitySub = _profileLogic.connectivityStream.listen((connected) {
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
    _checkInitialConnectivity();
  }

  final ProfileLogic _profileLogic;
  StreamSubscription<bool>? _connectivitySub;

  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isConnected = true;
  bool _isOfflineError = false;
  bool _isUnauthorized = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  bool get isOfflineError => _isOfflineError;
  bool get isUnauthorized => _isUnauthorized;
  String? get errorMessage => _errorMessage;

  Future<void> _checkInitialConnectivity() async {
    try {
      _isConnected = await _profileLogic.hasInternet();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadProfile({String? token, bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    _isOfflineError = false;
    _isUnauthorized = false;
    notifyListeners();

    try {
      final result = await _profileLogic.getOwnProfile(token: token);
      _profile = result;
      _isConnected = true;
    } on NoInternetException catch (e) {
      _errorMessage = e.message;
      _isOfflineError = true;
      _isConnected = false;
    } on UnauthorizedException catch (e) {
      _errorMessage = e.message;
      _isUnauthorized = true;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = AppStrings.failedLoadProfile;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null || _isOfflineError) {
      _errorMessage = null;
      _isOfflineError = false;
      notifyListeners();
    }
  }

  void reset() {
    _profile = null;
    _isLoading = false;
    _isOfflineError = false;
    _isUnauthorized = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
