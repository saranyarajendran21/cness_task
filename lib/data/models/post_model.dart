/// Paginated response wrapper for `GET /api/user/posts/get/front/latest`.
class FeedResponse {
  const FeedResponse({
    required this.count,
    required this.rows,
  });

  final int count;
  final List<PostModel> rows;

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'];
    final rows = rawRows is List
        ? rawRows
            .whereType<Map<String, dynamic>>()
            .map(PostModel.fromJson)
            .toList()
        : <PostModel>[];

    return FeedResponse(
      count: _parseInt(json['count'], rows.length),
      rows: rows,
    );
  }
}

/// Home feed post item.
class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.file,
    required this.fileType,
    required this.content,
    required this.isPoll,
    required this.pollId,
    required this.topicId,
    this.topic,
    required this.visibility,
    required this.postStatus,
    required this.isReported,
    required this.productId,
    required this.feeling,
    required this.locationId,
    this.location,
    required this.createdAt,
    required this.files,
    required this.followersCount,
    required this.likesCount,
    required this.commentsCount,
    required this.totalCommentCount,
    required this.shareCount,
    required this.repostCount,
    required this.ifFollowing,
    required this.isSaved,
    required this.isLiked,
    required this.ifFriend,
    required this.isRequested,
    this.user,
    this.profile,
    required this.postTags,
    required this.postTypeId,
    this.postType,
    required this.postTypeCategories,
    required this.postTypeSubCategories,
    required this.isRepost,
    this.repostedPost,
    this.repostedByUser,
    this.reaction,
  });

  final String id;
  final String userId;
  final String file;
  final String fileType;
  final String content;
  final bool isPoll;
  final String pollId;
  final String topicId;
  final TopicModel? topic;
  final int visibility;
  final String postStatus;
  final bool isReported;
  final String productId;
  final String feeling;
  final String locationId;
  final PostLocationModel? location;
  final String createdAt;
  final List<PostFileModel> files;
  final int followersCount;
  final int likesCount;
  final int commentsCount;
  final int totalCommentCount;
  final int shareCount;
  final int repostCount;
  final bool ifFollowing;
  final bool isSaved;
  final bool isLiked;
  final bool ifFriend;
  final bool isRequested;
  final PostUserModel? user;
  final PostProfileModel? profile;
  final List<PostTagModel> postTags;
  final String postTypeId;
  final PostTypeModel? postType;
  final List<dynamic> postTypeCategories;
  final List<dynamic> postTypeSubCategories;
  final bool isRepost;
  final PostModel? repostedPost;
  final PostUserModel? repostedByUser;
  final dynamic reaction;

  String get authorName {
    final fullName = profile?.fullName ?? '';
    if (fullName.isNotEmpty) return fullName;
    final username = user?.username ?? '';
    if (username.isNotEmpty) return username;
    return 'CNESS Member';
  }

  String get avatarUrl => profile?.profilePicture ?? '';

  /// Combines `files` list and fallback `file` field into unified media items.
  List<PostFileModel> get mediaItems {
    if (files.isNotEmpty) {
      return files.where((f) => f.file.trim().isNotEmpty).toList();
    }
    if (file.trim().isNotEmpty) {
      return [PostFileModel(id: id, file: file, fileType: fileType)];
    }
    return const [];
  }

  int get effectiveCommentCount =>
      totalCommentCount > 0 ? totalCommentCount : commentsCount;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final topicJson = json['topic'];
    final locationJson = json['location'];
    final userJson = json['user'];
    final profileJson = json['profile'];
    final postTypeJson = json['post_type'];
    final repostedPostJson = json['reposted_post'];
    final repostedByUserJson = json['reposted_by_user'];

    final rawFiles = json['files'];
    final files = rawFiles is List
        ? rawFiles
            .whereType<Map<String, dynamic>>()
            .map(PostFileModel.fromJson)
            .toList()
        : <PostFileModel>[];

    final rawTags = json['post_tags'];
    final postTags = rawTags is List
        ? rawTags
            .whereType<Map<String, dynamic>>()
            .map(PostTagModel.fromJson)
            .toList()
        : <PostTagModel>[];

    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? 'image',
      content: json['content']?.toString() ?? '',
      isPoll: _parseBool(json['is_poll']),
      pollId: json['poll_id']?.toString() ?? '',
      topicId: json['topic_id']?.toString() ?? '',
      topic: topicJson is Map<String, dynamic>
          ? TopicModel.fromJson(topicJson)
          : null,
      visibility: _parseInt(json['visibility'], 1),
      postStatus: json['post_status']?.toString() ?? '',
      isReported: _parseBool(json['is_reported']),
      productId: json['product_id']?.toString() ?? '',
      feeling: json['feeling']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      location: locationJson is Map<String, dynamic>
          ? PostLocationModel.fromJson(locationJson)
          : null,
      createdAt: json['createdAt']?.toString() ?? '',
      files: files,
      followersCount: _parseInt(json['followers_count']),
      likesCount: _parseInt(json['likes_count']),
      commentsCount: _parseInt(json['comments_count']),
      totalCommentCount: _parseInt(json['total_comment_count']),
      shareCount: _parseInt(json['share_count']),
      repostCount: _parseInt(json['repost_count']),
      ifFollowing: _parseBool(json['if_following']),
      isSaved: _parseBool(json['is_saved']),
      isLiked: _parseBool(json['is_liked']),
      ifFriend: _parseBool(json['if_friend']),
      isRequested: _parseBool(json['is_requested']),
      user: userJson is Map<String, dynamic>
          ? PostUserModel.fromJson(userJson)
          : null,
      profile: profileJson is Map<String, dynamic>
          ? PostProfileModel.fromJson(profileJson)
          : null,
      postTags: postTags,
      postTypeId: json['post_type_id']?.toString() ?? '',
      postType: postTypeJson is Map<String, dynamic>
          ? PostTypeModel.fromJson(postTypeJson)
          : null,
      postTypeCategories:
          (json['post_type_categories'] as List?) ?? const [],
      postTypeSubCategories:
          (json['post_type_sub_categories'] as List?) ?? const [],
      isRepost: _parseBool(json['is_repost']),
      repostedPost: repostedPostJson is Map<String, dynamic>
          ? PostModel.fromJson(repostedPostJson)
          : null,
      repostedByUser: repostedByUserJson is Map<String, dynamic>
          ? PostUserModel.fromJson(repostedByUserJson)
          : null,
      reaction: json['reaction'],
    );
  }

  PostModel copyWith({
    bool? isLiked,
    int? likesCount,
    bool? isSaved,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      file: file,
      fileType: fileType,
      content: content,
      isPoll: isPoll,
      pollId: pollId,
      topicId: topicId,
      topic: topic,
      visibility: visibility,
      postStatus: postStatus,
      isReported: isReported,
      productId: productId,
      feeling: feeling,
      locationId: locationId,
      location: location,
      createdAt: createdAt,
      files: files,
      followersCount: followersCount,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      totalCommentCount: totalCommentCount,
      shareCount: shareCount,
      repostCount: repostCount,
      ifFollowing: ifFollowing,
      isSaved: isSaved ?? this.isSaved,
      isLiked: isLiked ?? this.isLiked,
      ifFriend: ifFriend,
      isRequested: isRequested,
      user: user,
      profile: profile,
      postTags: postTags,
      postTypeId: postTypeId,
      postType: postType,
      postTypeCategories: postTypeCategories,
      postTypeSubCategories: postTypeSubCategories,
      isRepost: isRepost,
      repostedPost: repostedPost,
      repostedByUser: repostedByUser,
      reaction: reaction,
    );
  }
}

class TopicModel {
  const TopicModel({required this.id, required this.name});

  final String id;
  final String name;

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class PostLocationModel {
  const PostLocationModel({required this.name, required this.address});

  final String name;
  final String address;

  factory PostLocationModel.fromJson(Map<String, dynamic> json) {
    return PostLocationModel(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

class PostFileModel {
  const PostFileModel({
    required this.id,
    required this.file,
    required this.fileType,
  });

  final String id;
  final String file;
  final String fileType;

  bool get isVideo => fileType.toLowerCase().contains('video');

  factory PostFileModel.fromJson(Map<String, dynamic> json) {
    return PostFileModel(
      id: json['id']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? 'image',
    );
  }
}

class PostUserModel {
  const PostUserModel({required this.id, required this.username});

  final String id;
  final String username;

  factory PostUserModel.fromJson(Map<String, dynamic> json) {
    return PostUserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}

class PostProfileModel {
  const PostProfileModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String profilePicture;

  String get fullName => '$firstName $lastName'.trim();

  factory PostProfileModel.fromJson(Map<String, dynamic> json) {
    return PostProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
    );
  }
}

class PostTagModel {
  const PostTagModel({
    required this.taggedUserId,
    this.taggedUser,
  });

  final String taggedUserId;
  final TaggedUserModel? taggedUser;

  factory PostTagModel.fromJson(Map<String, dynamic> json) {
    final taggedJson = json['tagged_user'];
    return PostTagModel(
      taggedUserId: json['tagged_user_id']?.toString() ?? '',
      taggedUser: taggedJson is Map<String, dynamic>
          ? TaggedUserModel.fromJson(taggedJson)
          : null,
    );
  }
}

class TaggedUserModel {
  const TaggedUserModel({
    required this.id,
    required this.username,
    this.profile,
  });

  final String id;
  final String username;
  final PostProfileModel? profile;

  String get displayName {
    final full = profile?.fullName ?? '';
    return full.isNotEmpty ? full : username;
  }

  factory TaggedUserModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    return TaggedUserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profile: profileJson is Map<String, dynamic>
          ? PostProfileModel.fromJson(profileJson)
          : null,
    );
  }
}

class PostTypeModel {
  const PostTypeModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory PostTypeModel.fromJson(Map<String, dynamic> json) {
    return PostTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
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
