import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/post_model.dart';
import '../../logic/dashboard_logic.dart';

// Home feed post card matching the Dashboard layout (Image 2).
class PostCardWidget extends StatelessWidget {
  const PostCardWidget({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onSaveTap,
    this.onCommentTap,
    this.onShareTap,
    this.onCopyLinkTap,
    this.onReportTap,
    this.onNotInterestedTap,
  });

  final PostModel post;
  final VoidCallback onLikeTap;
  final VoidCallback onSaveTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onCopyLinkTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onNotInterestedTap;

  @override
  Widget build(BuildContext context) {
    final displayPost =
        post.isRepost && post.repostedPost != null ? post.repostedPost! : post;
    final media = displayPost.mediaItems;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isRepost && post.repostedByUser != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.repeat_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reposted by ${post.repostedByUser!.username}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          _PostHeader(
            post: displayPost,
            isSaved: post.isSaved,
            onSaveTap: onSaveTap,
            onShareTap: onShareTap,
            onCopyLinkTap: onCopyLinkTap,
            onReportTap: onReportTap,
            onNotInterestedTap: onNotInterestedTap,
          ),
          if (displayPost.topic != null &&
              displayPost.topic!.name.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softBlueBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayPost.topic!.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
          if (displayPost.content.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              displayPost.content.trim(),
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (media.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PostMediaGallery(media: media),
          ],
          const SizedBox(height: 12),
          Text(
            '${post.likesCount} Likes · ${post.effectiveCommentCount} Comments · ${post.shareCount} Shares',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _CircleActionButton(
                icon: post.isLiked
                    ? Icons.thumb_up_rounded
                    : Icons.thumb_up_outlined,
                isActive: post.isLiked,
                onTap: onLikeTap,
              ),
              const SizedBox(width: 10),
              _CircleActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: onCommentTap ?? () {},
              ),
              const SizedBox(width: 10),
              _CircleActionButton(
                icon: Icons.reply_rounded,
                onTap: onShareTap ?? () {},
              ),
              const Spacer(),
              if (post.isLiked || post.reaction != null)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.youReacted,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.favorite_rounded,
                      color: AppColors.errorRed,
                      size: 18,
                    ),
                  ],
                )
              else
                InkWell(
                  onTap: onSaveTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    child: Icon(
                      post.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 20,
                      color: post.isSaved
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({
    required this.post,
    required this.isSaved,
    required this.onSaveTap,
    this.onShareTap,
    this.onCopyLinkTap,
    this.onReportTap,
    this.onNotInterestedTap,
  });

  final PostModel post;
  final bool isSaved;
  final VoidCallback onSaveTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onCopyLinkTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onNotInterestedTap;

  String _buildTagSummary() {
    if (post.postTags.isEmpty) return '';
    final first = post.postTags.first.taggedUser?.displayName ?? '';
    if (first.isEmpty) return '';
    if (post.postTags.length == 1) return ' with $first';
    return ' with $first and ${post.postTags.length - 1} others';
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required String label,
    required Widget icon,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = post.avatarUrl;
    final tagSummary = _buildTagSummary();
    final timeAgo = DashboardLogic.formatRelativeTime(post.createdAt);
    final locationName = post.location?.name.trim() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: AppColors.softBlueBg,
          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
          child: avatar.isEmpty
              ? Text(
                  post.authorName.isNotEmpty
                      ? post.authorName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (tagSummary.isNotEmpty)
                      TextSpan(
                        text: tagSummary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.public_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      [
                        timeAgo,
                        if (post.feeling.trim().isNotEmpty)
                          'Feeling ${post.feeling}',
                        if (locationName.isNotEmpty) locationName,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: AppStrings.postOptionsTooltip,
          color: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 6,
          offset: const Offset(0, 42),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.tabTrackBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          onSelected: (value) {
            switch (value) {
              case 'copy_link':
                onCopyLinkTap?.call();
              case 'save':
                onSaveTap();
              case 'share':
                onShareTap?.call();
              case 'report':
                onReportTap?.call();
              case 'not_interested':
                onNotInterestedTap?.call();
            }
          },
          itemBuilder: (_) => [
            _buildMenuItem(
              value: 'copy_link',
              label: AppStrings.copyPostLink,
              icon: const Icon(
                Icons.copy_rounded,
                size: 20,
                color: AppColors.primaryBlue,
              ),
            ),
            _buildMenuItem(
              value: 'save',
              label:
                  isSaved ? AppStrings.unsaveThisPost : AppStrings.saveThisPost,
              icon: Icon(
                isSaved
                    ? Icons.bookmark_remove_rounded
                    : Icons.bookmark_rounded,
                size: 20,
                color: AppColors.primaryBlue,
              ),
            ),
            _buildMenuItem(
              value: 'share',
              label: AppStrings.share,
              icon: Transform.flip(
                flipX: true,
                child: const Icon(
                  Icons.reply_rounded,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            _buildMenuItem(
              value: 'report',
              label: AppStrings.report,
              icon: const Icon(
                Icons.warning_rounded,
                size: 20,
                color: AppColors.primaryBlue,
              ),
            ),
            _buildMenuItem(
              value: 'not_interested',
              label: AppStrings.notInterested,
              icon: const Icon(
                Icons.visibility_off_rounded,
                size: 20,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PostMediaGallery extends StatelessWidget {
  const _PostMediaGallery({required this.media});

  final List<PostFileModel> media;

  @override
  Widget build(BuildContext context) {
    if (media.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: _MediaTile(item: media.first),
        ),
      );
    }

    final displayItems = media.take(3).toList();
    final remaining = media.length - displayItems.length;

    return SizedBox(
      height: 175,
      child: Row(
        children: List.generate(displayItems.length, (index) {
          final isLast = index == displayItems.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _MediaTile(item: displayItems[index]),
                    if (isLast && remaining > 0)
                      Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Text(
                          '+$remaining',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item});

  final PostFileModel item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.file,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (_, _, _) => Container(
            color: AppColors.softBlueBg,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        if (item.isVideo)
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 26,
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.softBlueBg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 17,
          color: isActive ? AppColors.white : AppColors.primaryBlue,
        ),
      ),
    );
  }
}
