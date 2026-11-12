import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../logic/validators.dart';
import '../../providers/auth_provider.dart';
import '../widgets/cness_logo.dart';
import '../widgets/error_state_widget.dart';
import 'dashboard_screen.dart';

/// Login Screen matching Image 1 using MVVM + Provider.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _prefilledEmail = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_prefilledEmail) {
      final savedEmail = context.read<AuthProvider>().savedEmail;
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
      _prefilledEmail = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _handleExploreWithoutLogin() {
    context.read<AuthProvider>().enterGuestMode();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _showInfoSnackBar(String message) {
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

    return Scaffold(
      backgroundColor: AppColors.headerDark,
      body: Column(
        children: [
          _LoginHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthSegmentedToggle(
                      isLoginTab: auth.isLoginTab,
                      onChanged: auth.setAuthTab,
                    ),
                    const SizedBox(height: 22),
                    if (!auth.isLoginTab)
                      _SignUpPlaceholder(
                        onSwitchToLogin: () => auth.setAuthTab(true),
                      )
                    else
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _RequiredLabel(text: AppStrings.emailLabel),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              validator: Validators.validateEmail,
                              onChanged: (_) => auth.clearError(),
                              decoration: _inputDecoration(
                                hintText: AppStrings.emailHint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _RequiredLabel(text: AppStrings.passwordLabel),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: auth.obscurePassword,
                              textInputAction: TextInputAction.done,
                              validator: Validators.validatePassword,
                              onChanged: (_) => auth.clearError(),
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: _inputDecoration(
                                hintText: AppStrings.passwordHint,
                                suffixIcon: IconButton(
                                  onPressed: auth.togglePasswordVisibility,
                                  icon: Icon(
                                    auth.obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: auth.rememberMe,
                                    onChanged: (value) =>
                                        auth.setRememberMe(value ?? false),
                                    activeColor: AppColors.primaryBlue,
                                    side: const BorderSide(
                                      color: AppColors.textMuted,
                                      width: 1.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      auth.setRememberMe(!auth.rememberMe),
                                  child: const Text(
                                    AppStrings.rememberMe,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => _showInfoSnackBar(
                                    AppStrings.forgotPasswordSoon,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 32),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    AppStrings.forgotPassword,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.linkBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (auth.errorMessage != null) ...[
                              const SizedBox(height: 14),
                              ErrorBanner(
                                message: auth.errorMessage!,
                                isOffline: auth.isOfflineError,
                                onDismiss: auth.clearError,
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  disabledBackgroundColor:
                                      AppColors.primaryBlue.withValues(alpha: 0.65),
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.3,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : const Text(
                                        AppStrings.logIn,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: TextButton(
                                onPressed: _handleExploreWithoutLogin,
                                child: const Text(
                                  AppStrings.exploreWithoutLogin,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.linkBlue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.linkBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(color: AppColors.cardBorder),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    AppStrings.orSeparator,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: AppColors.cardBorder),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SocialLoginButton(
                              label: AppStrings.continueWithGoogle,
                              leading: const GoogleGIcon(size: 20),
                              onTap: () => _showInfoSnackBar(
                                AppStrings.googleNotConfigured,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SocialLoginButton(
                              label: AppStrings.continueWithFacebook,
                              leading: const Icon(
                                Icons.facebook_rounded,
                                color: Color(0xFF1877F2),
                                size: 22,
                              ),
                              onTap: () => _showInfoSnackBar(
                                AppStrings.facebookNotConfigured,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14.5),
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.4),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerDark,
            AppColors.headerMid,
            AppColors.headerLight,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -40,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            top: -15,
            left: -5,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CnessLogo(iconSize: 32, fontSize: 24),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.getStarted,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.loginSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthSegmentedToggle extends StatelessWidget {
  const _AuthSegmentedToggle({
    required this.isLoginTab,
    required this.onChanged,
  });

  final bool isLoginTab;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tabTrackBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              title: AppStrings.logIn,
              selected: isLoginTab,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              title: AppStrings.signUp,
              selected: !isLoginTab,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.errorRed),
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.leading,
    required this.onTap,
  });

  final String label;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.inputBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpPlaceholder extends StatelessWidget {
  const _SignUpPlaceholder({required this.onSwitchToLogin});

  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_add_alt_1_rounded,
            size: 40,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.createAccount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.signUpDisabledMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSwitchToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(AppStrings.goToLogIn),
          ),
        ],
      ),
    );
  }
}
