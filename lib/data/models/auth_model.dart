/// Request body for `POST /api/auth/login`.
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
      };
}

/// Authenticated user payload returned by `POST /api/auth/login`.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.mainName,
    required this.margaretName,
    required this.profilePicture,
    required this.completedStep,
    required this.personOrganizationComplete,
    required this.karmaCredits,
    required this.isAdult,
    required this.isSeller,
    required this.isLibrary,
    required this.isDisqualify,
  });

  final String id;
  final String name;
  final String mainName;
  final String margaretName;
  final String profilePicture;
  final int completedStep;
  final int personOrganizationComplete;
  final int karmaCredits;
  final bool isAdult;
  final bool isSeller;
  final bool isLibrary;
  final bool isDisqualify;

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    if (mainName.trim().isNotEmpty) return mainName.trim();
    return 'User';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mainName: json['main_name']?.toString() ?? '',
      margaretName: json['margaret_name']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
      completedStep: _parseInt(json['completed_step']),
      personOrganizationComplete:
          _parseInt(json['person_organization_complete']),
      karmaCredits: _parseInt(json['karma_credits']),
      isAdult: _parseBool(json['is_adult']),
      isSeller: _parseBool(json['is_seller']),
      isLibrary: _parseBool(json['is_library']),
      isDisqualify: _parseBool(json['is_disqualify']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'main_name': mainName,
        'margaret_name': margaretName,
        'profile_picture': profilePicture,
        'completed_step': completedStep,
        'person_organization_complete': personOrganizationComplete,
        'karma_credits': karmaCredits,
        'is_adult': isAdult,
        'is_seller': isSeller,
        'is_library': isLibrary,
        'is_disqualify': isDisqualify,
      };
}

/// Inner login data (`jwt`, `refresh_token`, `user`).
class LoginResponse {
  const LoginResponse({
    required this.jwt,
    required this.refreshToken,
    required this.user,
    this.message,
  });

  final String jwt;
  final String refreshToken;
  final UserModel user;
  final String? message;

  factory LoginResponse.fromJson(
    Map<String, dynamic> data, {
    String? message,
  }) {
    final userJson = data['user'];
    return LoginResponse(
      jwt: data['jwt']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
      user: userJson is Map<String, dynamic>
          ? UserModel.fromJson(userJson)
          : UserModel.fromJson(const {}),
      message: message,
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
