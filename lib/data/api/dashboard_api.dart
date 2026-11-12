import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';

/// Remote API service for Dashboard endpoints (story strip & home feed).
class DashboardApi {
  const DashboardApi({required this._apiClient});

  final ApiClient _apiClient;

  /// Calls `GET /api/story` with Bearer JWT.
  Future<StoryListResponse> fetchStories({
    required String token,
    int pageNo = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultLimit,
  }) async {
    final envelope = await _apiClient.get(
      ApiConstants.storiesPath,
      token: token,
      queryParams: {
        'page_no': pageNo,
        'limit': limit,
      },
    );

    final innerData = ApiClient.unwrapData(envelope);
    return StoryListResponse.fromJson(innerData);
  }

  /// Calls `GET /api/user/posts/get/front/latest` with Bearer JWT.
  Future<FeedResponse> fetchHomeFeed({
    required String token,
    int pageNo = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultLimit,
    String? postTypeSlug,
    String? postTypeCategorySlug,
    String? postTypeSubCategorySlug,
  }) async {
    final envelope = await _apiClient.get(
      ApiConstants.homeFeedPath,
      token: token,
      queryParams: {
        'page_no': pageNo.toString(),
        'limit': limit.toString(),
        if (postTypeSlug != null && postTypeSlug.isNotEmpty)
          'post_type_slug': postTypeSlug,
        if (postTypeCategorySlug != null && postTypeCategorySlug.isNotEmpty)
          'post_type_category_slug': postTypeCategorySlug,
        if (postTypeSubCategorySlug != null &&
            postTypeSubCategorySlug.isNotEmpty)
          'post_type_sub_category_slug': postTypeSubCategorySlug,
      },
    );

    final innerData = ApiClient.unwrapData(envelope);
    return FeedResponse.fromJson(innerData);
  }
}
