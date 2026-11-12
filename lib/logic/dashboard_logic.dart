import '../core/constants/api_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/errors/app_exception.dart';
import '../core/network/network_info.dart';
import '../core/storage/token_storage.dart';
import '../data/api/dashboard_api.dart';
import '../data/models/post_model.dart';
import '../data/models/story_model.dart';

class DashboardLogic {
  const DashboardLogic({
    required this._dashboardApi,
    required this._tokenStorage,
    required this._networkInfo,
  });

  final DashboardApi _dashboardApi;
  final TokenStorage _tokenStorage;
  final NetworkInfo _networkInfo;

  Stream<bool> get connectivityStream => _networkInfo.onConnectivityChanged;

  Future<bool> hasInternet() => _networkInfo.isConnected;

  Future<String> _requireToken([String? overrideToken]) async {
    if (overrideToken != null && overrideToken.isNotEmpty) {
      return overrideToken;
    }
    final stored = await _tokenStorage.getJwt();
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    if (ApiConstants.defaultAuthToken.isNotEmpty) {
      return ApiConstants.defaultAuthToken;
    }
    throw const UnauthorizedException(
      AppStrings.loginRequiredStoriesAndFeed,
      401,
    );
  }

  Future<StoryListResponse> getStories({
    String? token,
    int pageNo = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultLimit,
  }) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      throw const NoInternetException();
    }
    final jwt = await _requireToken(token);
    return _dashboardApi.fetchStories(
      token: jwt,
      pageNo: pageNo,
      limit: limit,
    );
  }

  Future<FeedResponse> getHomeFeed({
    String? token,
    int pageNo = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultLimit,
    String? postTypeSlug,
    String? postTypeCategorySlug,
    String? postTypeSubCategorySlug,
  }) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      throw const NoInternetException();
    }
    final jwt = await _requireToken(token);
    return _dashboardApi.fetchHomeFeed(
      token: jwt,
      pageNo: pageNo,
      limit: limit,
      postTypeSlug: postTypeSlug,
      postTypeCategorySlug: postTypeCategorySlug,
      postTypeSubCategorySlug: postTypeSubCategorySlug,
    );
  }

  /// Formats ISO timestamp strings into concise relative labels (e.g. "2 hours ago").
  static String formatRelativeTime(String isoString) {
    if (isoString.trim().isEmpty) return AppStrings.justNow;
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) return isoString;

    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.isNegative || diff.inSeconds < 60) return AppStrings.justNow;
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'min' : 'mins'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}
