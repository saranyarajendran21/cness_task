import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/errors/app_exception.dart';
import '../data/models/post_model.dart';
import '../data/models/story_model.dart';
import '../logic/dashboard_logic.dart';

/// MVVM ViewModel managing Dashboard stories, home feed, filters, and connectivity.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider({required this._dashboardLogic}) {
    _connectivitySub = _dashboardLogic.connectivityStream.listen((connected) {
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
    _checkInitialConnectivity();
  }

  final DashboardLogic _dashboardLogic;
  StreamSubscription<bool>? _connectivitySub;

  bool _isConnected = true;
  bool _isUnauthorized = false;

  // Stories state
  List<StoryModel> _stories = [];
  int _totalStories = 0;
  int _storyPage = ApiConstants.defaultPage;
  bool _isLoadingStories = false;
  bool _isLoadingMoreStories = false;
  String? _storiesError;
  bool _isStoriesOffline = false;

  // Home feed state
  List<PostModel> _posts = [];
  int _totalPosts = 0;
  int _feedPage = ApiConstants.defaultPage;
  bool _isLoadingFeed = false;
  bool _isLoadingMoreFeed = false;
  String? _feedError;
  bool _isFeedOffline = false;

  // Optional feed filters
  String? _postTypeSlug;
  String? _postTypeCategorySlug;
  String? _postTypeSubCategorySlug;

  // Getters
  bool get isConnected => _isConnected;
  bool get isUnauthorized => _isUnauthorized;

  List<StoryModel> get stories => List.unmodifiable(_stories);
  int get totalStories => _totalStories;
  bool get isLoadingStories => _isLoadingStories;
  bool get isLoadingMoreStories => _isLoadingMoreStories;
  String? get storiesError => _storiesError;
  bool get isStoriesOffline => _isStoriesOffline;
  bool get hasMoreStories => _stories.length < _totalStories;

  List<PostModel> get posts => List.unmodifiable(_posts);
  int get totalPosts => _totalPosts;
  bool get isLoadingFeed => _isLoadingFeed;
  bool get isLoadingMoreFeed => _isLoadingMoreFeed;
  String? get feedError => _feedError;
  bool get isFeedOffline => _isFeedOffline;
  bool get hasMorePosts => _posts.length < _totalPosts;

  String? get postTypeSlug => _postTypeSlug;
  String? get postTypeCategorySlug => _postTypeCategorySlug;
  String? get postTypeSubCategorySlug => _postTypeSubCategorySlug;

  Future<void> _checkInitialConnectivity() async {
    try {
      _isConnected = await _dashboardLogic.hasInternet();
      notifyListeners();
    } catch (_) {}
  }

  /// Loads both the Story Strip and Home Feed concurrently.
  Future<void> loadDashboard({
    String? token,
    bool refresh = false,
  }) async {
    _isUnauthorized = false;
    _isConnected = await _dashboardLogic.hasInternet();

    await Future.wait([
      loadStories(token: token, refresh: refresh),
      loadFeed(token: token, refresh: refresh),
    ]);
  }

  Future<void> loadStories({
    String? token,
    bool refresh = false,
  }) async {
    if (_isLoadingStories && !refresh) return;

    _isLoadingStories = true;
    _storiesError = null;
    _isStoriesOffline = false;
    _storyPage = ApiConstants.defaultPage;
    notifyListeners();

    try {
      final response = await _dashboardLogic.getStories(
        token: token,
        pageNo: _storyPage,
        limit: ApiConstants.defaultLimit,
      );
      _stories = response.rows;
      _totalStories = response.count;
      _isConnected = true;
    } on NoInternetException catch (e) {
      _storiesError = e.message;
      _isStoriesOffline = true;
      _isConnected = false;
    } on UnauthorizedException catch (e) {
      _storiesError = e.message;
      _isUnauthorized = true;
    } on AppException catch (e) {
      _storiesError = e.message;
    } catch (_) {
      _storiesError = AppStrings.failedLoadStories;
    }

    _isLoadingStories = false;
    notifyListeners();
  }

  Future<void> loadMoreStories({String? token}) async {
    if (_isLoadingMoreStories || _isLoadingStories || !hasMoreStories) return;

    _isLoadingMoreStories = true;
    notifyListeners();

    final nextPage = _storyPage + 1;
    try {
      final response = await _dashboardLogic.getStories(
        token: token,
        pageNo: nextPage,
        limit: ApiConstants.defaultLimit,
      );
      _storyPage = nextPage;
      _totalStories = response.count;
      _stories = [..._stories, ...response.rows];
    } on AppException {
      // Keep existing stories if pagination fails.
    }

    _isLoadingMoreStories = false;
    notifyListeners();
  }

  Future<void> loadFeed({
    String? token,
    bool refresh = false,
  }) async {
    if (_isLoadingFeed && !refresh) return;

    _isLoadingFeed = true;
    _feedError = null;
    _isFeedOffline = false;
    _feedPage = ApiConstants.defaultPage;
    notifyListeners();

    try {
      final response = await _dashboardLogic.getHomeFeed(
        token: token,
        pageNo: _feedPage,
        limit: ApiConstants.defaultLimit,
        postTypeSlug: _postTypeSlug,
        postTypeCategorySlug: _postTypeCategorySlug,
        postTypeSubCategorySlug: _postTypeSubCategorySlug,
      );
      _posts = response.rows;
      _totalPosts = response.count;
      _isConnected = true;
    } on NoInternetException catch (e) {
      _feedError = e.message;
      _isFeedOffline = true;
      _isConnected = false;
    } on UnauthorizedException catch (e) {
      _feedError = e.message;
      _isUnauthorized = true;
    } on AppException catch (e) {
      _feedError = e.message;
    } catch (_) {
      _feedError = AppStrings.failedLoadHomeFeed;
    }

    _isLoadingFeed = false;
    notifyListeners();
  }

  Future<String?> loadMorePosts({String? token}) async {
    if (_isLoadingMoreFeed || _isLoadingFeed || !hasMorePosts) return null;

    _isLoadingMoreFeed = true;
    notifyListeners();

    String? paginationError;
    final nextPage = _feedPage + 1;

    try {
      final response = await _dashboardLogic.getHomeFeed(
        token: token,
        pageNo: nextPage,
        limit: ApiConstants.defaultLimit,
        postTypeSlug: _postTypeSlug,
        postTypeCategorySlug: _postTypeCategorySlug,
        postTypeSubCategorySlug: _postTypeSubCategorySlug,
      );
      _feedPage = nextPage;
      _totalPosts = response.count;
      _posts = [..._posts, ...response.rows];
    } on AppException catch (e) {
      paginationError = e.message;
    } catch (_) {
      paginationError = AppStrings.failedLoadMorePosts;
    }

    _isLoadingMoreFeed = false;
    notifyListeners();
    return paginationError;
  }

  Future<void> applyFilters({
    String? postTypeSlug,
    String? postTypeCategorySlug,
    String? postTypeSubCategorySlug,
    String? token,
  }) async {
    _postTypeSlug = postTypeSlug;
    _postTypeCategorySlug = postTypeCategorySlug;
    _postTypeSubCategorySlug = postTypeSubCategorySlug;
    await loadFeed(token: token, refresh: true);
  }

  void markStoryViewed(String storyId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index == -1) return;
    _stories = List.of(_stories)
      ..[index] = _stories[index].copyWith(isViewed: true);
    notifyListeners();
  }

  void togglePostLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final current = _posts[index];
    final nextLiked = !current.isLiked;
    final nextCount = nextLiked
        ? current.likesCount + 1
        : (current.likesCount > 0 ? current.likesCount - 1 : 0);
    _posts = List.of(_posts)
      ..[index] = current.copyWith(isLiked: nextLiked, likesCount: nextCount);
    notifyListeners();
  }

  void togglePostSave(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final current = _posts[index];
    _posts = List.of(_posts)
      ..[index] = current.copyWith(isSaved: !current.isSaved);
    notifyListeners();
  }

  /// Removes a post locally from the feed when the user selects Not interested.
  void hidePost(String postId) {
    final next = _posts.where((p) => p.id != postId).toList();
    if (next.length == _posts.length) return;
    _posts = next;
    if (_totalPosts > 0) {
      _totalPosts -= 1;
    }
    notifyListeners();
  }

  void reset() {
    _stories = [];
    _posts = [];
    _totalStories = 0;
    _totalPosts = 0;
    _storyPage = ApiConstants.defaultPage;
    _feedPage = ApiConstants.defaultPage;
    _storiesError = null;
    _feedError = null;
    _isUnauthorized = false;
    _postTypeSlug = null;
    _postTypeCategorySlug = null;
    _postTypeSubCategorySlug = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
