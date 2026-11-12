import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.isOffline = false,
    this.actionLabel = AppStrings.retry,
    this.onRetry,
    this.onDismiss,
  });

  final String message;
  final bool isOffline;
  final String actionLabel;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final accentColor = isOffline ? AppColors.warningAmber : AppColors.errorRed;
    final bgColor =
        isOffline ? const Color(0xFFFFFBEB) : AppColors.errorSoftBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isOffline ? const Color(0xFF92400E) : AppColors.errorRed,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: Text(actionLabel),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
        ],
      ),
    );
  }
}

/// Full-card error state with retry action for feed/story sections.
class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    super.key,
    required this.message,
    this.title,
    this.actionLabel,
    this.actionIcon,
    this.isOffline = false,
    required this.onRetry,
  });

  final String message;
  final String? title;
  final String? actionLabel;
  final IconData? actionIcon;
  final bool isOffline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ??
        (isOffline
            ? AppStrings.noInternetTitle
            : AppStrings.unableToLoadTitle);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                isOffline ? const Color(0xFFFEF3C7) : AppColors.errorSoftBg,
            child: Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
              color: isOffline ? AppColors.warningAmber : AppColors.errorRed,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            resolvedTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(actionIcon ?? Icons.refresh_rounded, size: 18),
            label: Text(actionLabel ?? AppStrings.tryAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
