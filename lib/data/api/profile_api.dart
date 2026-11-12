import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/profile_model.dart';

/// Remote API service for own profile endpoint.
class ProfileApi {
  const ProfileApi({required this._apiClient});

  final ApiClient _apiClient;

  /// Calls `GET /api/profile` with Bearer JWT and no parameters.
  Future<ProfileModel> fetchOwnProfile({required String token}) async {
    final envelope = await _apiClient.get(
      ApiConstants.profilePath,
      token: token,
    );

    final innerData = ApiClient.unwrapData(envelope);
    return ProfileModel.fromJson(innerData);
  }
}
