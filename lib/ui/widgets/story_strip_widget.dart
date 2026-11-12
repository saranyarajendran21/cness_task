import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/story_model.dart';

/// Horizontal Home Story Strip matching the Dashboard design (Image 2).
class StoryStripWidget extends StatelessWidget {
  const StoryStripWidget({
    super.key,
    required this.stories,
    required this.isLoading,
    required this.isLoadingMore,
    this.errorMessage,
    this.currentUser,
    required this.onRetry,
    required this.onStoryTap,
    required this.onAddThoughtTap,
    this.onLoadMore,
  });

  final List<StoryModel> stories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final UserModel? currentUser;
  final VoidCallback onRetry;
  final ValueChanged<StoryModel> onStoryTap;
  final VoidCallback onAddThoughtTap;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && stories.isEmpty && !isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_stories_outlined,
                  color: AppColors.errorRed, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMessage!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = isLoading && stories.isEmpty
        ? 5
        : 1 + stories.length + (isLoadingMore ? 1 : 0);

    return SizedBox(
      height: 158,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (onLoadMore != null &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 120) {
            onLoadMore!();
          }
          return false;
        },
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _AddThoughtCard(
                user: currentUser,
                onTap: onAddThoughtTap,
              );
            }

            if (isLoading && stories.isEmpty) {
              return const _StorySkeletonCard();
            }

            final storyIndex = index - 1;
            if (storyIndex >= stories.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final story = stories[storyIndex];
            return _StoryItemCard(
              story: story,
              onTap: () => onStoryTap(story),
            );
          },
        ),
      ),
    );
  }
}

class _AddThoughtCard extends StatelessWidget {
  const _AddThoughtCard({this.user, required this.onTap});

  final UserModel? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = user?.profilePicture ?? '';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            SizedBox(
              height: 132,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 122,
                    width: 92,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.headerMid, AppColors.headerDark],
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatar.isNotEmpty
                        ? Image.network(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(
                                Icons.auto_awesome,
                                color: AppColors.logoAmber,
                                size: 30,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.auto_awesome,
                              color: AppColors.logoAmber,
                              size: 30,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              AppStrings.addThought,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryItemCard extends StatelessWidget {
  const _StoryItemCard({
    required this.story,
    required this.onTap,
  });

  final StoryModel story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgUrl = story.displayImage;
    final avatarUrl = story.avatarUrl;
    final ringColor =
        story.isViewed ? AppColors.textMuted : AppColors.primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            SizedBox(
              height: 132,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 122,
                    width: 92,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.headerMid.withValues(alpha: 0.15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (bgUrl.isNotEmpty)
                          Image.network(
                            bgUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _StoryFallbackBg(name: story.authorName),
                          )
                        else
                          _StoryFallbackBg(name: story.authorName),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.25),
                              ],
                            ),
                          ),
                        ),
                        if (story.videoFile.isNotEmpty)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.play_circle_filled_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        border: Border.all(color: ringColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.softBlueBg,
                        backgroundImage:
                            avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? Text(
                                story.authorName.isNotEmpty
                                    ? story.authorName[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              story.authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryFallbackBg extends StatelessWidget {
  const _StoryFallbackBg({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF1E1B4B)],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'S',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StorySkeletonCard extends StatelessWidget {
  const _StorySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Container(
            height: 122,
            width: 92,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          Container(
            height: 10,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
