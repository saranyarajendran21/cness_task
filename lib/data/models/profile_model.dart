/// Model for `GET /api/profile` response payload.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.profilePicture,
    required this.profileBanner,
    required this.gender,
    required this.dob,
    required this.ageRange,
    required this.opinionOnConsciousness,
    required this.professionalBio,
    required this.countryCode,
    required this.phoneNo,
    required this.email,
    required this.address,
    required this.countryId,
    required this.stateId,
    required this.personalVisionStatement,
    required this.socialLinks,
    required this.communicationSms,
    required this.communicationEmail,
    required this.communicationWhatsapp,
    required this.location,
    required this.interests,
    required this.professions,
    required this.education,
    required this.workExperience,
    this.country,
    this.state,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.mutualFriendsCount,
    this.identifyUploaded,
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String bio;
  final String profilePicture;
  final String profileBanner;
  final String gender;
  final String dob;
  final String ageRange;
  final String opinionOnConsciousness;
  final String professionalBio;
  final String countryCode;
  final String phoneNo;
  final String email;
  final String address;
  final String countryId;
  final String stateId;
  final String personalVisionStatement;
  final Map<String, dynamic> socialLinks;
  final bool communicationSms;
  final bool communicationEmail;
  final bool communicationWhatsapp;
  final Map<String, dynamic> location;
  final List<ProfileNamedItem> interests;
  final List<ProfileNamedItem> professions;
  final List<EducationItem> education;
  final List<WorkExperienceItem> workExperience;
  final ProfileNamedItem? country;
  final ProfileNamedItem? state;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final int mutualFriendsCount;
  final dynamic identifyUploaded;

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isNotEmpty ? combined : 'CNESS Member';
  }

  String get formattedPhone {
    final code = countryCode.trim();
    final phone = phoneNo.trim();
    if (code.isEmpty && phone.isEmpty) return '';
    if (code.isEmpty) return phone;
    if (phone.isEmpty) return '';
    return '$code $phone';
  }

  String get formattedLocation {
    final parts = <String>[];
    final city = location['city']?.toString().trim() ??
        location['name']?.toString().trim() ??
        '';
    final stateFromLocation = location['state']?.toString().trim() ?? '';
    final stateName = (state?.name.trim().isNotEmpty ?? false)
        ? state!.name.trim()
        : stateFromLocation;
    final countryFromLocation = location['country']?.toString().trim() ?? '';
    final countryName = (country?.name.trim().isNotEmpty ?? false)
        ? country!.name.trim()
        : countryFromLocation;

    if (city.isNotEmpty) parts.add(city);
    if (stateName.isNotEmpty && !parts.contains(stateName)) parts.add(stateName);
    if (countryName.isNotEmpty && !parts.contains(countryName)) {
      parts.add(countryName);
    }
    return parts.join(', ');
  }

  String get subtitle {
    if (professionalBio.trim().isNotEmpty) return professionalBio.trim();
    if (professions.isNotEmpty) {
      return professions.map((p) => p.name).where((n) => n.isNotEmpty).join(' | ');
    }
    return '';
  }

  String get quoteText {
    if (personalVisionStatement.trim().isNotEmpty) {
      return personalVisionStatement.trim();
    }
    return bio.trim();
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawInterests = json['interests'];
    final rawProfessions = json['professions'];
    final rawEducation = json['education'];
    final rawWork = json['work_experience'];
    final rawCountry = json['country'];
    final rawState = json['state'];
    final rawSocialLinks = json['social_links'];
    final rawLocation = json['location'];

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
      profileBanner: json['profile_banner']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      ageRange: json['age_range']?.toString() ?? '',
      opinionOnConsciousness:
          json['opinion_on_counsciouness']?.toString() ?? '',
      professionalBio: json['professional_bio']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      phoneNo: json['phone_no']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      countryId: json['country_id']?.toString() ?? '',
      stateId: json['state_id']?.toString() ?? '',
      personalVisionStatement:
          json['personal_vision_statement']?.toString() ?? '',
      socialLinks: rawSocialLinks is Map<String, dynamic>
          ? rawSocialLinks
          : <String, dynamic>{},
      communicationSms: _parseBool(json['communication_sms']),
      communicationEmail: _parseBool(json['communication_email']),
      communicationWhatsapp: _parseBool(json['communication_whatsapp']),
      location: rawLocation is Map<String, dynamic>
          ? rawLocation
          : <String, dynamic>{},
      interests: rawInterests is List
          ? rawInterests
              .whereType<Map<String, dynamic>>()
              .map(ProfileNamedItem.fromJson)
              .toList()
          : <ProfileNamedItem>[],
      professions: rawProfessions is List
          ? rawProfessions
              .whereType<Map<String, dynamic>>()
              .map(ProfileNamedItem.fromJson)
              .toList()
          : <ProfileNamedItem>[],
      education: rawEducation is List
          ? rawEducation
              .whereType<Map<String, dynamic>>()
              .map(EducationItem.fromJson)
              .toList()
          : <EducationItem>[],
      workExperience: rawWork is List
          ? rawWork
              .whereType<Map<String, dynamic>>()
              .map(WorkExperienceItem.fromJson)
              .toList()
          : <WorkExperienceItem>[],
      country: rawCountry is Map<String, dynamic>
          ? ProfileNamedItem.fromJson(rawCountry)
          : null,
      state: rawState is Map<String, dynamic>
          ? ProfileNamedItem.fromJson(rawState)
          : null,
      postsCount: _parseInt(json['posts_count']),
      followersCount: _parseInt(json['followers_count']),
      followingCount: _parseInt(json['following_count']),
      friendsCount: _parseInt(json['friends_count']),
      mutualFriendsCount: _parseInt(json['mutual_friends_count']),
      identifyUploaded: json['identify_uploaded'],
    );
  }
}

class ProfileNamedItem {
  const ProfileNamedItem({required this.id, required this.name});

  final String id;
  final String name;

  factory ProfileNamedItem.fromJson(Map<String, dynamic> json) {
    return ProfileNamedItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class WorkExperienceItem {
  const WorkExperienceItem({
    required this.id,
    required this.title,
    required this.company,
    required this.duration,
    required this.location,
    required this.description,
    this.logoUrl = '',
  });

  final String id;
  final String title;
  final String company;
  final String duration;
  final String location;
  final String description;
  final String logoUrl;

  factory WorkExperienceItem.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ??
            json['role'] ??
            json['position'] ??
            json['designation'] ??
            '')
        .toString();
    final company = (json['company'] ??
            json['company_name'] ??
            json['organization'] ??
            '')
        .toString();
    final start = (json['start_date'] ?? json['from'] ?? '').toString().trim();
    final isCurrent = _parseBool(json['is_current']) ||
        _parseBool(json['currently_working']);
    final end = isCurrent
        ? 'Present'
        : (json['end_date'] ?? json['to'] ?? '').toString().trim();
    final duration = [start, end].where((s) => s.isNotEmpty).join(' - ');

    return WorkExperienceItem(
      id: json['id']?.toString() ?? '',
      title: title,
      company: company,
      duration: duration,
      location: (json['location'] ?? json['city'] ?? '').toString(),
      description: (json['description'] ?? json['summary'] ?? '').toString(),
      logoUrl: (json['logo'] ?? json['company_logo'] ?? '').toString(),
    );
  }
}

class EducationItem {
  const EducationItem({
    required this.id,
    required this.degree,
    required this.institution,
    required this.duration,
    required this.location,
    required this.description,
  });

  final String id;
  final String degree;
  final String institution;
  final String duration;
  final String location;
  final String description;

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    final degree = (json['degree'] ??
            json['field_of_study'] ??
            json['course'] ??
            json['title'] ??
            '')
        .toString();
    final institution = (json['institution'] ??
            json['school'] ??
            json['university'] ??
            json['college'] ??
            '')
        .toString();
    final start = (json['start_date'] ?? json['from'] ?? '').toString().trim();
    final end = (json['end_date'] ?? json['to'] ?? '').toString().trim();
    final duration = [start, end].where((s) => s.isNotEmpty).join(' - ');

    return EducationItem(
      id: json['id']?.toString() ?? '',
      degree: degree,
      institution: institution,
      duration: duration,
      location: (json['location'] ?? json['city'] ?? '').toString(),
      description: (json['description'] ?? json['summary'] ?? '').toString(),
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
