/// Paginated response wrapper for `GET /api/story`.
class StoryListResponse {
  const StoryListResponse({
    required this.count,
    required this.rows,
  });

  final int count;
  final List<StoryModel> rows;

  factory StoryListResponse.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'];
    final rows = rawRows is List
        ? rawRows
            .whereType<Map<String, dynamic>>()
            .map(StoryModel.fromJson)
            .toList()
        : <StoryModel>[];

    return StoryListResponse(
      count: _parseInt(json['count'], rows.length),
      rows: rows,
    );
  }
}

/// Individual story item in the Home story strip.
class StoryModel {
  const StoryModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.videoId,
    required this.duration,
    required this.file,
    required this.thumbnail,
    required this.videoFile,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isViewed,
    required this.isLiked,
    required this.moderationStatus,
    required this.videoType,
    required this.feeling,
    this.location,
    required this.r2Key,
    required this.thumbnailR2Key,
    this.storyUser,
  });

  final String id;
  final String userId;
  final String description;
  final String videoId;
  final int duration;
  final String file;
  final String thumbnail;
  final String videoFile;
  final String createdAt;
  final String updatedAt;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isViewed;
  final bool isLiked;
  final String moderationStatus;
  final String videoType;
  final String feeling;
  final StoryLocationModel? location;
  final String r2Key;
  final String thumbnailR2Key;
  final StoryUserModel? storyUser;

  String get displayImage {
    if (thumbnail.trim().isNotEmpty) return thumbnail.trim();
    if (file.trim().isNotEmpty) return file.trim();
    return storyUser?.profile?.profilePicture.trim() ?? '';
  }

  String get authorName {
    final profileName = storyUser?.profile?.fullName ?? '';
    if (profileName.isNotEmpty) return profileName;
    final username = storyUser?.username ?? '';
    if (username.isNotEmpty) return username;
    return 'Story';
  }

  String get avatarUrl => storyUser?.profile?.profilePicture ?? '';

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];
    final storyUserJson = json['storyuser'];

    return StoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      videoId: json['video_id']?.toString() ?? '',
      duration: _parseInt(json['duration']),
      file: json['file']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      videoFile: json['video_file']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      likesCount: _parseInt(json['likes_count']),
      commentsCount: _parseInt(json['comments_count']),
      viewsCount: _parseInt(json['views_count']),
      isViewed: _parseBool(json['is_viewed']),
      isLiked: _parseBool(json['is_liked']),
      moderationStatus: json['moderation_status']?.toString() ?? '',
      videoType: json['video_type']?.toString() ?? '',
      feeling: json['feeling']?.toString() ?? '',
      location: locationJson is Map<String, dynamic>
          ? StoryLocationModel.fromJson(locationJson)
          : null,
      r2Key: json['r2_key']?.toString() ?? '',
      thumbnailR2Key: json['thumbnail_r2_key']?.toString() ?? '',
      storyUser: storyUserJson is Map<String, dynamic>
          ? StoryUserModel.fromJson(storyUserJson)
          : null,
    );
  }

  StoryModel copyWith({bool? isViewed, bool? isLiked, int? likesCount}) {
    return StoryModel(
      id: id,
      userId: userId,
      description: description,
      videoId: videoId,
      duration: duration,
      file: file,
      thumbnail: thumbnail,
      videoFile: videoFile,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      viewsCount: viewsCount,
      isViewed: isViewed ?? this.isViewed,
      isLiked: isLiked ?? this.isLiked,
      moderationStatus: moderationStatus,
      videoType: videoType,
      feeling: feeling,
      location: location,
      r2Key: r2Key,
      thumbnailR2Key: thumbnailR2Key,
      storyUser: storyUser,
    );
  }
}

class StoryLocationModel {
  const StoryLocationModel({required this.name, required this.address});

  final String name;
  final String address;

  factory StoryLocationModel.fromJson(Map<String, dynamic> json) {
    return StoryLocationModel(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

class StoryUserModel {
  const StoryUserModel({
    required this.id,
    required this.username,
    this.profile,
  });

  final String id;
  final String username;
  final StoryUserProfileModel? profile;

  factory StoryUserModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    return StoryUserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profile: profileJson is Map<String, dynamic>
          ? StoryUserProfileModel.fromJson(profileJson)
          : null,
    );
  }
}

class StoryUserProfileModel {
  const StoryUserProfileModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String profilePicture;

  String get fullName => '$firstName $lastName'.trim();

  factory StoryUserProfileModel.fromJson(Map<String, dynamic> json) {
    return StoryUserProfileModel(
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
    );
  }
}

int _parseInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _parseBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return fallback;
}
