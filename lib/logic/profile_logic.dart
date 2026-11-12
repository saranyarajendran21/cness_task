import '../core/constants/api_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/errors/app_exception.dart';
import '../core/network/network_info.dart';
import '../core/storage/token_storage.dart';
import '../data/api/profile_api.dart';
import '../data/models/profile_model.dart';

/// Business logic layer for own Profile fetching and session checks.
class ProfileLogic {
  const ProfileLogic({
    required this._profileApi,
    required this._tokenStorage,
    required this._networkInfo,
  });

  final ProfileApi _profileApi;
  final TokenStorage _tokenStorage;
  final NetworkInfo _networkInfo;

  Stream<bool> get connectivityStream => _networkInfo.onConnectivityChanged;

  Future<bool> hasInternet() => _networkInfo.isConnected;

  Future<ProfileModel> getOwnProfile({String? token}) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      throw const NoInternetException();
    }

    String? jwt = (token != null && token.isNotEmpty)
        ? token
        : await _tokenStorage.getJwt();
    if ((jwt == null || jwt.isEmpty) &&
        ApiConstants.defaultAuthToken.isNotEmpty) {
      jwt = ApiConstants.defaultAuthToken;
    }
    if (jwt == null || jwt.isEmpty) {
      throw const UnauthorizedException(
        AppStrings.loginRequiredProfile,
        401,
      );
    }

    return _profileApi.fetchOwnProfile(token: jwt);
  }
}
