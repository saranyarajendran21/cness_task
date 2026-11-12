/// Centralized constant UI, validation, and error strings for CNESS.
class AppStrings {
  AppStrings._();

  // Brand & General
  static const String appName = 'CNESS';
  static const String defaultMemberName = 'CNESS Member';
  static const String guestUser = 'Guest User';
  static const String guestPreview = 'Guest Preview';
  static const String emDash = '—';
  static const String justNow = 'Just now';

  // Validation
  static const String emailRequired = 'Email is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordRequired = 'Password is required.';
  static const String passwordTooShort =
      'Password must be at least 6 characters.';

  // Network & Error Messages
  static const String noInternet =
      'No internet connection. Please check your Wi-Fi or mobile data and try again.';
  static const String requestTimeout = 'Request timed out. Please try again.';
  static const String sessionExpiredUnauthorized =
      'Session expired or unauthorized. Please log in again.';
  static const String unauthorizedFallback =
      'Unauthorized request. Please log in again.';
  static const String validationFallback =
      'Invalid input. Please check your details.';
  static const String parseError =
      'Unable to parse server response. Please try again.';
  static const String unknownError = 'Something went wrong. Please try again.';
  static const String unexpectedLoginError =
      'Unexpected error while logging in. Please try again.';
  static const String failedLoadProfile =
      'Failed to load profile. Please try again.';
  static const String failedLoadStories = 'Failed to load stories.';
  static const String failedLoadHomeFeed = 'Failed to load home feed.';
  static const String failedLoadMorePosts = 'Could not load more posts.';
  static const String loginRequiredStoriesAndFeed =
      'Please log in to view stories and home feed.';
  static const String loginRequiredProfile =
      'Please log in to view your profile.';

  static String networkError(String detail) => 'Network error: $detail';
  static String serverError(int statusCode) =>
      'Server error ($statusCode). Please try again later.';
  static String requestFailed(int statusCode) => 'Request failed ($statusCode).';

  // Common Actions & Alerts
  static const String retry = 'Retry';
  static const String tryAgain = 'Try Again';
  static const String logIn = 'Log In';
  static const String signUp = 'Sign Up';
  static const String logOut = 'Log Out';
  static const String goToLogin = 'Go to Login';
  static const String back = 'Back';
  static const String noInternetTitle = 'No Internet Connection';
  static const String unableToLoadTitle = 'Unable to Load Content';
  static const String offlineBannerMessage =
      'You are currently offline. Check your connection and retry.';
  static const String offlineCardMessage =
      'You are currently offline. Check your connection and try again.';
  static const String sessionExpiredBanner =
      'Session expired. Please log in again.';
  static const String sessionExpiredTitle = 'Session Expired';
  static const String loginRequiredTitle = 'Login Required';

  static String comingSoon(String title) => '$title coming soon.';

  // Login Screen
  static const String getStarted = 'Get Started';
  static const String loginSubtitle =
      'Create an account or log in to explore about our app';
  static const String emailLabel = 'Email';
  static const String emailHint = 'Sridharan@cness.co';
  static const String passwordLabel = 'Password';
  static const String passwordHint = '••••••••';
  static const String rememberMe = 'Remember me';
  static const String forgotPassword = 'Forgot Password ?';
  static const String forgotPasswordSoon =
      'Forgot Password flow will be available soon.';
  static const String exploreWithoutLogin = 'Explore without login';
  static const String orSeparator = 'Or';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithFacebook = 'Continue with Facebook';
  static const String googleNotConfigured =
      'Google Sign-In is not configured yet.';
  static const String facebookNotConfigured =
      'Facebook Sign-In is not configured yet.';
  static const String createAccount = 'Create Account';
  static const String signUpDisabledMessage =
      'Sign up is not yet enabled in this build. Please switch to Log In with your CNESS credentials.';
  static const String goToLogIn = 'Go to Log In';

  // Dashboard Screen
  static const String dashboardGuestBanner =
      'You are browsing in guest mode. Log in with your CNESS account to load stories and the home feed.';
  static const String dashboardGuestSnackBar =
      'Please log in to load personalized stories and feed.';
  static const String dashboardSessionExpiredMessage =
      'Your session has expired. Please log in again to load stories and your home feed.';
  static const String search = 'Search';
  static const String voicePrompt = 'Voice prompt';
  static const String messages = 'Messages';
  static const String drivenAi = 'Driven AI';
  static const String arivenAi = 'Ariven AI';
  static const String createAPost = 'Create a Post';
  static const String liveVideo = 'Live Video';
  static const String marketplace = 'Marketplace';
  static const String directory = 'Directory';
  static const String bestPractises = 'Best Practises';
  static const String addThought = 'Add Thought';
  static const String comments = 'Comments';
  static const String sharePost = 'Share Post';
  static const String noPostsYet = 'No posts found in your home feed yet.';
  static const String loadMorePosts = 'Load more posts';
  static const String allCaughtUp = 'You are all caught up';
  static const String viewProfile = 'View Profile';
  static const String navHome = 'Home';
  static const String navExplore = 'Explore';
  static const String navCommunity = 'Community';
  static const String navProfile = 'Profile';

  static String promptPlaceholder(String firstName) =>
      'What would you like to do $firstName?';
  static String karmaCreditsLabel(int credits) => 'Karma Credits: $credits';

  // Post Card & Menu
  static const String postSaved = 'Post saved.';
  static const String postUnsaved = 'Post removed from saved.';
  static const String postReported =
      'Post reported. Thank you for your feedback.';
  static const String postHidden = 'Post hidden from your feed.';
  static const String postLinkCopied = 'Post link copied to clipboard.';
  static const String youReacted = 'You Reacted';
  static const String postOptionsTooltip = 'Post options';
  static const String copyPostLink = 'Copy post link';
  static const String saveThisPost = 'Save this post';
  static const String unsaveThisPost = 'Unsave this post';
  static const String share = 'Share';
  static const String report = 'Report';
  static const String notInterested = 'Not interested';

  // Profile Screen
  static const String profileGuestMessage =
      'You are browsing in guest mode. Log in to view your CNESS profile.';
  static const String profileSessionExpiredMessage =
      'Your session has expired. Please log in again to view your profile.';
  static const String profileLinkCopied = 'Profile link copied.';
  static const String bestPractiseTab = 'Best Practise';
  static const String bestPractisesSoon = 'Best Practises coming soon.';
  static const String communitiesTab = 'Communities';
  static const String communitiesSoon = 'Communities coming soon.';
  static const String whatsapp = 'Whatsapp';
  static const String facebook = 'Facebook';
  static const String tiktok = 'Tiktok';
  static const String website = 'Website';
  static const String basicInfo = 'Basic Info';
  static const String interest = 'Interest';
  static const String professions = 'Professions';
  static const String opinionOnConsciousness = 'Opinion on Consciousness';
  static const String noBasicInfoYet = 'No basic info added yet.';
  static const String contact = 'Contact';
  static const String phoneNumber = 'Phone Number';
  static const String address = 'Address';
  static const String location = 'Location';
  static const String experience = 'Experience';
  static const String noWorkExperienceYet = 'No work experience added yet.';
  static const String defaultRole = 'Role';
  static const String education = 'Education';
  static const String noEducationYet = 'No education details added yet.';

  static String notLinked(String label) => '$label not linked';
}
