import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/story_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/profile_provider.dart';
import '../widgets/cness_logo.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/story_strip_widget.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

/// Dashboard Screen matching Image 2 (Header, Quick Actions, Story Strip, Home Feed).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final auth = context.read<AuthProvider>();
    final dashboard = context.read<DashboardProvider>();
    if (auth.hasAccessToken) {
      dashboard.loadDashboard(token: auth.activeToken);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 250) {
      final auth = context.read<AuthProvider>();
      final dashboard = context.read<DashboardProvider>();
      if (auth.hasAccessToken) {
        dashboard.loadMorePosts(token: auth.activeToken);
      }
    }
  }

  Future<void> _handleRefresh() async {
    final auth = context.read<AuthProvider>();
    final dashboard = context.read<DashboardProvider>();
    if (!auth.hasAccessToken) {
      _showGuestPrompt();
      return;
    }
    await dashboard.loadDashboard(token: auth.activeToken, refresh: true);
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

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _showGuestPrompt() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(AppStrings.dashboardGuestSnackBar),
          action: SnackBarAction(
            label: AppStrings.logIn,
            onPressed: _handleLogout,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openStoryViewer(StoryModel story) {
    context.read<DashboardProvider>().markStoryViewed(story.id);
    showDialog<void>(
      context: context,
      builder: (ctx) => _StoryPreviewDialog(story: story),
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

  void _showComingSoon(String title) {
    _showSnackBar(AppStrings.comingSoon(title));
  }

  Future<void> _copyPostLink(String postId) async {
    final link = '${ApiConstants.baseUrl}/post/$postId';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    _showSnackBar(AppStrings.postLinkCopied);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: _DashboardBottomNav(
        currentIndex: _bottomNavIndex,
        user: user,
        onTap: (index) {
          if (index == 4) {
            _showAccountSheet(auth);
            return;
          }
          setState(() => _bottomNavIndex = index);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _DashboardTopHeader(
                user: user,
                onSearchTap: () => _showComingSoon(AppStrings.search),
                onMicTap: () => _showComingSoon(AppStrings.voicePrompt),
                onMessagesTap: () => _showComingSoon(AppStrings.messages),
                onPromptTap: () => _showComingSoon(AppStrings.drivenAi),
              ),
            ),
            if (!dashboard.isConnected &&
                (dashboard.stories.isNotEmpty || dashboard.posts.isNotEmpty))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ErrorBanner(
                    message: AppStrings.offlineBannerMessage,
                    isOffline: true,
                    onRetry: _handleRefresh,
                  ),
                ),
              ),
            if (dashboard.isUnauthorized &&
                (dashboard.stories.isNotEmpty || dashboard.posts.isNotEmpty))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ErrorBanner(
                    message: AppStrings.sessionExpiredBanner,
                    actionLabel: AppStrings.logIn,
                    onRetry: _handleLogout,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionPill(
                        icon: Icons.add_photo_alternate_outlined,
                        iconColor: AppColors.successGreen,
                        label: AppStrings.createAPost,
                        onTap: () => _showComingSoon(AppStrings.createAPost),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionPill(
                        icon: Icons.videocam_rounded,
                        iconColor: AppColors.liveRed,
                        label: AppStrings.liveVideo,
                        onTap: () => _showComingSoon(AppStrings.liveVideo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!auth.hasAccessToken)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ErrorStateCard(
                    title: AppStrings.loginRequiredTitle,
                    message: AppStrings.dashboardGuestBanner,
                    actionLabel: AppStrings.logIn,
                    actionIcon: Icons.login_rounded,
                    onRetry: _handleLogout,
                  ),
                ),
              )
            else if (dashboard.isUnauthorized &&
                dashboard.stories.isEmpty &&
                dashboard.posts.isEmpty)
              SliverToBoxAdapter(
                child: ErrorStateCard(
                  title: AppStrings.sessionExpiredTitle,
                  message: AppStrings.dashboardSessionExpiredMessage,
                  actionLabel: AppStrings.logIn,
                  actionIcon: Icons.login_rounded,
                  onRetry: _handleLogout,
                ),
              )
            else if (!dashboard.isConnected &&
                dashboard.stories.isEmpty &&
                dashboard.posts.isEmpty &&
                !dashboard.isLoadingStories &&
                !dashboard.isLoadingFeed)
              SliverToBoxAdapter(
                child: ErrorStateCard(
                  message: AppStrings.offlineCardMessage,
                  isOffline: true,
                  onRetry: _handleRefresh,
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: StoryStripWidget(
                  stories: dashboard.stories,
                  isLoading: dashboard.isLoadingStories,
                  isLoadingMore: dashboard.isLoadingMoreStories,
                  errorMessage:
                      dashboard.isUnauthorized ? null : dashboard.storiesError,
                  currentUser: user,
                  onRetry: () => dashboard.loadStories(
                      token: auth.activeToken, refresh: true),
                  onStoryTap: _openStoryViewer,
                  onAddThoughtTap: () => _showComingSoon(AppStrings.addThought),
                  onLoadMore: () =>
                      dashboard.loadMoreStories(token: auth.activeToken),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CategoryChipCard(
                          icon: Icons.shopping_bag_rounded,
                          iconColor: AppColors.marketplacePurple,
                          label: AppStrings.marketplace,
                          onTap: () => _showComingSoon(AppStrings.marketplace),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryChipCard(
                          icon: Icons.contacts_rounded,
                          iconColor: AppColors.directoryGreen,
                          label: AppStrings.directory,
                          onTap: () => _showComingSoon(AppStrings.directory),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryChipCard(
                          icon: Icons.diamond_rounded,
                          iconColor: AppColors.warningAmber,
                          label: AppStrings.bestPractises,
                          onTap: () =>
                              _showComingSoon(AppStrings.bestPractises),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (dashboard.isLoadingFeed && dashboard.posts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                )
              else if (!dashboard.isUnauthorized &&
                  dashboard.feedError != null &&
                  dashboard.posts.isEmpty)
                SliverToBoxAdapter(
                  child: ErrorStateCard(
                    message: dashboard.feedError!,
                    isOffline: dashboard.isFeedOffline,
                    onRetry: () => dashboard.loadFeed(
                        token: auth.activeToken, refresh: true),
                  ),
                )
              else if (dashboard.posts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        AppStrings.noPostsYet,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == dashboard.posts.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: dashboard.isLoadingMoreFeed
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primaryBlue,
                                  )
                                : dashboard.hasMorePosts
                                    ? TextButton(
                                        onPressed: () =>
                                            dashboard.loadMorePosts(
                                                token: auth.activeToken),
                                        child: const Text(
                                            AppStrings.loadMorePosts),
                                      )
                                    : const Text(
                                        AppStrings.allCaughtUp,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                          ),
                        );
                      }

                      final post = dashboard.posts[index];
                      return PostCardWidget(
                        post: post,
                        onLikeTap: () => dashboard.togglePostLike(post.id),
                        onSaveTap: () {
                          final wasSaved = post.isSaved;
                          dashboard.togglePostSave(post.id);
                          _showSnackBar(
                            wasSaved
                                ? AppStrings.postUnsaved
                                : AppStrings.postSaved,
                          );
                        },
                        onCommentTap: () => _showComingSoon(AppStrings.comments),
                        onShareTap: () => _showComingSoon(AppStrings.sharePost),
                        onCopyLinkTap: () => _copyPostLink(post.id),
                        onReportTap: () =>
                            _showSnackBar(AppStrings.postReported),
                        onNotInterestedTap: () {
                          dashboard.hidePost(post.id);
                          _showSnackBar(AppStrings.postHidden);
                        },
                      );
                    },
                    childCount: dashboard.posts.length + 1,
                  ),
                ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _showAccountSheet(AuthProvider auth) {
    final user = auth.user;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.softBlueBg,
                    backgroundImage: (user?.profilePicture ?? '').isNotEmpty
                        ? NetworkImage(user!.profilePicture)
                        : null,
                    child: (user?.profilePicture ?? '').isEmpty
                        ? const Icon(Icons.person, color: AppColors.primaryBlue)
                        : null,
                  ),
                  title: Text(
                    user?.displayName ?? AppStrings.guestUser,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    auth.isAuthenticated
                        ? AppStrings.karmaCreditsLabel(user?.karmaCredits ?? 0)
                        : AppStrings.guestPreview,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: const Text(
                    AppStrings.viewProfile,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openProfile();
                  },
                ),
                ListTile(
                  leading: Icon(
                    auth.isAuthenticated ? Icons.logout : Icons.login,
                    color: AppColors.errorRed,
                  ),
                  title: Text(
                    auth.isAuthenticated
                        ? AppStrings.logOut
                        : AppStrings.goToLogin,
                    style: const TextStyle(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleLogout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardTopHeader extends StatelessWidget {
  const _DashboardTopHeader({
    this.user,
    required this.onSearchTap,
    required this.onMicTap,
    required this.onMessagesTap,
    required this.onPromptTap,
  });

  final UserModel? user;
  final VoidCallback onSearchTap;
  final VoidCallback onMicTap;
  final VoidCallback onMessagesTap;
  final VoidCallback onPromptTap;

  @override
  Widget build(BuildContext context) {
    final firstName = (user?.displayName ?? 'there').split(' ').first;
    final avatar = user?.profilePicture ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerLight,
            AppColors.headerMid,
            AppColors.headerDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const CnessLogo(iconSize: 28, fontSize: 21),
                  const Spacer(),
                  _HeaderCircleIcon(
                    icon: Icons.search,
                    onTap: onSearchTap,
                  ),
                  const SizedBox(width: 8),
                  _HeaderCircleIcon(
                    icon: Icons.notifications,
                    onTap: onMicTap,
                  ),
                  const SizedBox(width: 8),
                  _HeaderCircleIcon(
                    icon: Icons.chat_rounded,
                    onTap: onMessagesTap,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onPromptTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.softBlueBg,
                        backgroundImage:
                            avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        child: avatar.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 17,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppStrings.promptPlaceholder(firstName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        AppStrings.arivenAi,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.motion_photos_on_rounded,
                        size: 18,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCircleIcon extends StatelessWidget {
  const _HeaderCircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.linkBlue),
      ),
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChipCard extends StatelessWidget {
  const _CategoryChipCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({
    required this.currentIndex,
    this.user,
    required this.onTap,
  });

  final int currentIndex;
  final UserModel? user;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = user?.profilePicture ?? '';

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textSecondary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: AppStrings.navHome,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore_rounded),
          label: AppStrings.navExplore,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront_rounded),
          label: AppStrings.marketplace,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.diversity_3_outlined),
          activeIcon: Icon(Icons.diversity_3_rounded),
          label: AppStrings.navCommunity,
        ),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.softBlueBg,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.primaryBlue,
                  )
                : null,
          ),
          label: AppStrings.navProfile,
        ),
      ],
    );
  }
}

class _StoryPreviewDialog extends StatelessWidget {
  const _StoryPreviewDialog({required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.displayImage;
    return Dialog(
      backgroundColor: AppColors.headerDark,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.auto_stories,
                            color: Colors.white54,
                            size: 56,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.auto_stories,
                          color: Colors.white54,
                          size: 56,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.softBlueBg,
                      backgroundImage: story.avatarUrl.isNotEmpty
                          ? NetworkImage(story.avatarUrl)
                          : null,
                      child: story.avatarUrl.isEmpty
                          ? Text(
                              story.authorName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        story.authorName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (story.description.trim().isNotEmpty)
                  Text(
                    story.description,
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                if (story.feeling.trim().isNotEmpty ||
                    (story.location?.name.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: 8),
                  Text(
                    [
                      if (story.feeling.trim().isNotEmpty)
                        'Feeling ${story.feeling}',
                      if (story.location?.name.trim().isNotEmpty ?? false)
                        story.location!.name,
                    ].join(' · '),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  '${story.viewsCount} Views · ${story.likesCount} Likes · ${story.commentsCount} Comments',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
