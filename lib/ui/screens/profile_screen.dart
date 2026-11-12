import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/profile_provider.dart';
import '../widgets/error_state_widget.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile({bool refresh = false}) {
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    if (auth.hasAccessToken) {
      profileProvider.loadProfile(token: auth.activeToken, refresh: refresh);
    }
  }

  Future<void> _handleRefresh() async {
    final auth = context.read<AuthProvider>();
    if (!auth.hasAccessToken) return;
    await context
        .read<ProfileProvider>()
        .loadProfile(token: auth.activeToken, refresh: true);
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthProvider>();
    final dashboard = context.read<DashboardProvider>();
    final profile = context.read<ProfileProvider>();
    await auth.logout();
    dashboard.reset();
    profile.reset();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileState = context.watch<ProfileProvider>();
    final profile = profileState.profile;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeroSection(
                      profile: profile,
                      fallbackName: auth.user?.displayName ??
                          AppStrings.defaultMemberName,
                      fallbackAvatar: auth.user?.profilePicture ?? '',
                      onBackTap: _handleBack,
                      onShareTap: () =>
                          _showSnackBar(AppStrings.profileLinkCopied),
                      onSocialTap: (label, value) => _showSnackBar(
                        value.isNotEmpty
                            ? '$label: $value'
                            : AppStrings.notLinked(label),
                      ),
                    ),
                  if ((!profileState.isConnected ||
                          profileState.isOfflineError) &&
                      profile != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: ErrorBanner(
                        message: AppStrings.offlineBannerMessage,
                        isOffline: true,
                        onRetry: () => _loadProfile(refresh: true),
                      ),
                    ),
                  if (profileState.isUnauthorized && profile != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: ErrorBanner(
                        message: AppStrings.sessionExpiredBanner,
                        actionLabel: AppStrings.logIn,
                        onRetry: _handleLogout,
                      ),
                    ),
                  if (!auth.hasAccessToken)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ErrorStateCard(
                        title: AppStrings.loginRequiredTitle,
                        message: AppStrings.profileGuestMessage,
                        actionLabel: AppStrings.logIn,
                        actionIcon: Icons.login_rounded,
                        onRetry: _handleLogout,
                      ),
                    )
                  else if (profileState.isLoading && profile == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  else if (profileState.isUnauthorized && profile == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ErrorStateCard(
                        title: AppStrings.sessionExpiredTitle,
                        message: AppStrings.profileSessionExpiredMessage,
                        actionLabel: AppStrings.logIn,
                        actionIcon: Icons.login_rounded,
                        onRetry: _handleLogout,
                      ),
                    )
                  else if (profileState.errorMessage != null && profile == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ErrorStateCard(
                        message: profileState.errorMessage!,
                        isOffline: profileState.isOfflineError,
                        onRetry: () => _loadProfile(refresh: true),
                      ),
                    )
                  else if (profile != null) ...[
                    if (profileState.errorMessage != null &&
                        !profileState.isUnauthorized &&
                        !profileState.isOfflineError)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: ErrorBanner(
                          message: profileState.errorMessage!,
                          onRetry: () => _loadProfile(refresh: true),
                          onDismiss: profileState.clearError,
                        ),
                      ),
                    _ProfileBodySections(profile: profile),
                  ],
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),

          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SideEdgeTab(
                  label: AppStrings.bestPractiseTab,
                  onTap: () => _showSnackBar(AppStrings.bestPractisesSoon),
                ),
                const SizedBox(height: 8),
                _SideEdgeTab(
                  label: AppStrings.communitiesTab,
                  onTap: () => _showSnackBar(AppStrings.communitiesSoon),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroSection extends StatelessWidget {
  const _ProfileHeroSection({
    required this.profile,
    required this.fallbackName,
    required this.fallbackAvatar,
    required this.onBackTap,
    required this.onShareTap,
    required this.onSocialTap,
  });

  final ProfileModel? profile;
  final String fallbackName;
  final String fallbackAvatar;
  final VoidCallback onBackTap;
  final VoidCallback onShareTap;
  final void Function(String label, String value) onSocialTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (profile?.profilePicture.trim().isNotEmpty ?? false)
        ? profile!.profilePicture.trim()
        : fallbackAvatar;
    final displayName = profile?.fullName ?? fallbackName;
    final subtitle = profile?.subtitle ?? '';
    final quote = profile?.quoteText ?? '';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 0.88, 1.0],
          colors: [
            AppColors.headerDark,
            AppColors.headerLight,
            Color(0xFF9EA5DF),
            AppColors.white,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: -20,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            child: IgnorePointer(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onBackTap,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                          color: AppColors.headerDark,
                        ),
                        label: const Text(
                          AppStrings.back,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headerDark,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.headerDark,
                          elevation: 0,
                          minimumSize: const Size(76, 36),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: AppColors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onShareTap,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.reply_rounded,
                              size: 18,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.softBlueBg,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl.isEmpty
                          ? Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF38BDF8),
                        size: 19,
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (quote.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '"$quote"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _SocialLinksBar(
                    profile: profile,
                    onSocialTap: onSocialTap,
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLinksBar extends StatelessWidget {
  const _SocialLinksBar({
    required this.profile,
    required this.onSocialTap,
  });

  final ProfileModel? profile;
  final void Function(String label, String value) onSocialTap;

  @override
  Widget build(BuildContext context) {
    final links = profile?.socialLinks ?? const {};

    String valueFor(List<String> keys) {
      for (final k in keys) {
        final v = links[k]?.toString().trim() ?? '';
        if (v.isNotEmpty) return v;
      }
      return '';
    }

    final items = [
      (
        label: AppStrings.whatsapp,
        assetPath: 'assets/images/whatsapp.png',
        fallbackIcon: Icons.chat_rounded,
        value: valueFor(['whatsapp', 'whatsApp']),
      ),
      (
        label: AppStrings.facebook,
        assetPath: 'assets/images/facebook.png',
        fallbackIcon: Icons.facebook_rounded,
        value: valueFor(['facebook', 'fb']),
      ),
      (
        label: AppStrings.tiktok,
        assetPath: 'assets/images/tiktok.png',
        fallbackIcon: Icons.music_note_rounded,
        value: valueFor(['tiktok', 'tikTok']),
      ),
      (
        label: AppStrings.website,
        assetPath: 'assets/images/website.png',
        fallbackIcon: Icons.language_rounded,
        value: valueFor(['website', 'web', 'portfolio']),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.headerDark.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return InkWell(
            onTap: () => onSocialTap(item.label, item.value),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset(
                      item.assetPath,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        item.fallbackIcon,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileBodySections extends StatelessWidget {
  const _ProfileBodySections({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(AppStrings.basicInfo),
          const Divider(color: AppColors.cardBorder, height: 18),
          if (profile.interests.isNotEmpty) ...[
            const _FieldLabel(AppStrings.interest),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.interests
                  .where((e) => e.name.trim().isNotEmpty)
                  .map((item) => _IndigoTagChip(label: item.name))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.professions.isNotEmpty) ...[
            const _FieldLabel(AppStrings.professions),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.professions
                  .where((e) => e.name.trim().isNotEmpty)
                  .map((item) => _IndigoTagChip(label: item.name))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.opinionOnConsciousness.trim().isNotEmpty) ...[
            const _FieldLabel(AppStrings.opinionOnConsciousness),
            const SizedBox(height: 4),
            Text(
              profile.opinionOnConsciousness.trim(),
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.interests.isEmpty &&
              profile.professions.isEmpty &&
              profile.opinionOnConsciousness.trim().isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                AppStrings.noBasicInfoYet,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ),
          const SizedBox(height: 6),
          const _SectionTitle(AppStrings.contact),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ContactInfoBlock(
                  label: AppStrings.emailLabel,
                  value: profile.email.isNotEmpty
                      ? profile.email
                      : AppStrings.emDash,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: AppColors.cardBorder,
              ),
              Expanded(
                child: _ContactInfoBlock(
                  label: AppStrings.phoneNumber,
                  value: profile.formattedPhone.isNotEmpty
                      ? profile.formattedPhone
                      : AppStrings.emDash,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ContactInfoBlock(
            label: AppStrings.address,
            value: profile.address.trim().isNotEmpty
                ? profile.address
                : AppStrings.emDash,
          ),
          const SizedBox(height: 14),
          _ContactInfoBlock(
            label: AppStrings.location,
            value: profile.formattedLocation.isNotEmpty
                ? profile.formattedLocation
                : AppStrings.emDash,
          ),
          const SizedBox(height: 24),
          const _SectionTitle(AppStrings.experience),
          const SizedBox(height: 12),
          if (profile.workExperience.isEmpty)
            const Text(
              AppStrings.noWorkExperienceYet,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            )
          else
            ...profile.workExperience.map((item) => _TimelineItemTile(
                  title: item.title.isNotEmpty
                      ? item.title
                      : AppStrings.defaultRole,
                  subtitle: item.company,
                  duration: item.duration,
                  location: item.location,
                  description: item.description,
                  leading: _ExperienceLeadingIcon(logoUrl: item.logoUrl),
                )),
          const SizedBox(height: 20),
          const _SectionTitle(AppStrings.education),
          const SizedBox(height: 12),
          if (profile.education.isEmpty)
            const Text(
              AppStrings.noEducationYet,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            )
          else
            ...profile.education.map((item) => _TimelineItemTile(
                  title: item.degree.isNotEmpty
                      ? item.degree
                      : AppStrings.education,
                  subtitle: item.institution,
                  duration: item.duration,
                  location: item.location,
                  description: item.description,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.textMuted,
                      size: 26,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.headerDark,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.headerLight,
      ),
    );
  }
}

class _IndigoTagChip extends StatelessWidget {
  const _IndigoTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.headerMid,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ContactInfoBlock extends StatelessWidget {
  const _ContactInfoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ExperienceLeadingIcon extends StatelessWidget {
  const _ExperienceLeadingIcon({required this.logoUrl});

  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          logoUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultIcon(),
        ),
      );
    }
    return _defaultIcon();
  }

  Widget _defaultIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.headerMid,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.work_outline_rounded,
        color: AppColors.white,
        size: 24,
      ),
    );
  }
}

class _TimelineItemTile extends StatelessWidget {
  const _TimelineItemTile({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.location,
    required this.description,
    required this.leading,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String location;
  final String description;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                if (duration.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideEdgeTab extends StatelessWidget {
  const _SideEdgeTab({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.headerMid,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_drop_down_circle_outlined,
                color: AppColors.white,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
