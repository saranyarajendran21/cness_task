import '../core/constants/app_strings.dart';

/// Form and domain validators for authentication.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AppStrings.emailRequired;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final raw = value ?? '';
    if (raw.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (raw.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }
}
