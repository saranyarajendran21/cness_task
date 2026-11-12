import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cness_task/core/network/api_client.dart';
import 'package:cness_task/core/network/network_info.dart';
import 'package:cness_task/core/storage/token_storage.dart';
import 'package:cness_task/data/api/auth_api.dart';
import 'package:cness_task/data/api/dashboard_api.dart';
import 'package:cness_task/data/api/profile_api.dart';
import 'package:cness_task/data/models/post_model.dart';
import 'package:cness_task/logic/auth_logic.dart';
import 'package:cness_task/logic/dashboard_logic.dart';
import 'package:cness_task/logic/profile_logic.dart';
import 'package:cness_task/logic/validators.dart';
import 'package:cness_task/providers/auth_provider.dart';
import 'package:cness_task/providers/dashboard_provider.dart';
import 'package:cness_task/providers/profile_provider.dart';
import 'package:cness_task/ui/screens/login_screen.dart';
import 'package:cness_task/ui/screens/profile_screen.dart';
import 'package:cness_task/ui/widgets/post_card_widget.dart';

class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({this.connected = true});

  bool connected;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void emit(bool value) {
    connected = value;
    _controller.add(value);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Validators', () {
    test('rejects empty or invalid email and accepts valid email', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('Sridharan@cness.co'), isNull);
    });

    test('rejects empty or short password and accepts valid password', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('secret123'), isNull);
    });
  });

  group('AuthProvider & AuthApi', () {
    test('login fails with offline error when network is disconnected',
        () async {
      final networkInfo = FakeNetworkInfo(connected: false);
      final mockClient = MockClient((_) async => http.Response('{}', 200));
      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final authProvider = AuthProvider(
        authLogic: AuthLogic(
          authApi: AuthApi(apiClient: apiClient),
          tokenStorage: TokenStorage(),
          networkInfo: networkInfo,
        ),
      );

      final result = await authProvider.login(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(authProvider.isOfflineError, isTrue);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('login parses nested data.data envelope and persists JWT & user',
        () async {
      final networkInfo = FakeNetworkInfo(connected: true);
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/auth/login');
        expect(request.headers['Authorization'], isNull);

        return http.Response(
          jsonEncode({
            'success': {
              'status': true,
              'statusCode': 200,
              'message': 'Logged in successfully'
            },
            'data': {
              'data': {
                'jwt': 'jwt-token-123',
                'refresh_token': 'refresh-456',
                'user': {
                  'id': 'u1',
                  'name': 'Sri',
                  'main_name': 'Sridharan',
                  'margaret_name': '',
                  'profile_picture': 'https://example.com/avatar.png',
                  'completed_step': 2,
                  'person_organization_complete': 1,
                  'karma_credits': 50,
                  'is_adult': true,
                  'is_seller': false,
                  'is_library': false,
                  'is_disqualify': false,
                },
              },
            },
            'error': null,
          }),
          200,
        );
      });

      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final tokenStorage = TokenStorage();
      final authProvider = AuthProvider(
        authLogic: AuthLogic(
          authApi: AuthApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      authProvider.setRememberMe(true);

      final result = await authProvider.login(
        email: 'Sridharan@cness.co',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.jwt, 'jwt-token-123');
      expect(authProvider.user?.displayName, 'Sri');
      expect(await tokenStorage.getJwt(), 'jwt-token-123');
      expect(await tokenStorage.getSavedEmail(), 'Sridharan@cness.co');
    });

    test('login surfaces API error message when server rejects credentials',
        () async {
      final networkInfo = FakeNetworkInfo(connected: true);
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'success': {'status': false, 'statusCode': 401, 'message': 'Fail'},
            'data': null,
            'error': {'message': 'Invalid email or password'},
          }),
          401,
        );
      });

      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final authProvider = AuthProvider(
        authLogic: AuthLogic(
          authApi: AuthApi(apiClient: apiClient),
          tokenStorage: TokenStorage(),
          networkInfo: networkInfo,
        ),
      );

      final result = await authProvider.login(
        email: 'user@example.com',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
      expect(authProvider.errorMessage, 'Invalid email or password');
    });
  });

  group('DashboardProvider & DashboardApi', () {
    test('loads stories and home feed with Bearer JWT and supports pagination',
        () async {
      final networkInfo = FakeNetworkInfo(connected: true);
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer jwt-token-123');

        if (request.url.path == '/api/story') {
          expect(request.url.queryParameters['page_no'], '1');
          expect(request.url.queryParameters['limit'], '10');
          return http.Response(
            jsonEncode({
              'success': {'status': true, 'statusCode': 200, 'message': 'OK'},
              'data': {
                'data': {
                  'count': 1,
                  'rows': [
                    {
                      'id': 's1',
                      'user_id': 'u2',
                      'description': 'Morning yoga flow',
                      'video_id': '',
                      'duration': 15,
                      'file': 'https://example.com/story.jpg',
                      'thumbnail': 'https://example.com/thumb.jpg',
                      'video_file': '',
                      'createdAt': '2026-11-12T10:00:00Z',
                      'updatedAt': '2026-11-12T10:00:00Z',
                      'likes_count': 4,
                      'comments_count': 1,
                      'views_count': 20,
                      'is_viewed': false,
                      'is_liked': false,
                      'moderation_status': 'approved',
                      'video_type': 'story',
                      'feeling': 'peaceful',
                      'location': {'name': 'Chennai', 'address': 'India'},
                      'r2_key': '',
                      'thumbnail_r2_key': '',
                      'storyuser': {
                        'id': 'u2',
                        'username': 'elisa',
                        'profile': {
                          'user_id': 'u2',
                          'first_name': 'Elisa',
                          'last_name': 'S',
                          'profile_picture': '',
                        },
                      },
                    },
                  ],
                },
              },
              'error': null,
            }),
            200,
          );
        }

        if (request.url.path == '/api/user/posts/get/front/latest') {
          final page = request.url.queryParameters['page_no'];
          return http.Response(
            jsonEncode({
              'success': {'status': true, 'statusCode': 200, 'message': 'OK'},
              'data': {
                'data': {
                  'count': 2,
                  'rows': [
                    {
                      'id': 'p$page',
                      'user_id': 'u3',
                      'file': '',
                      'file_type': 'image',
                      'content': 'Post on page $page',
                      'is_poll': false,
                      'poll_id': '',
                      'topic_id': '',
                      'topic': {'id': 't1', 'name': 'Yoga'},
                      'visibility': 1,
                      'post_status': 'published',
                      'is_reported': false,
                      'product_id': '',
                      'feeling': '',
                      'location_id': '',
                      'location': null,
                      'createdAt': '2026-11-12T08:00:00Z',
                      'files': [
                        {
                          'id': 'f1',
                          'file': 'https://example.com/photo.jpg',
                          'file_type': 'image',
                        },
                      ],
                      'followers_count': 10,
                      'likes_count': 5,
                      'comments_count': 2,
                      'total_comment_count': 2,
                      'share_count': 1,
                      'repost_count': 0,
                      'if_following': false,
                      'is_saved': false,
                      'is_liked': false,
                      'if_friend': false,
                      'is_requested': false,
                      'user': {'id': 'u3', 'username': 'annamary'},
                      'profile': {
                        'id': 'pr1',
                        'user_id': 'u3',
                        'first_name': 'Anna',
                        'last_name': 'Mary',
                        'profile_picture': '',
                      },
                      'post_tags': [],
                      'post_type_id': 'pt1',
                      'post_type': {
                        'id': 'pt1',
                        'name': 'Article',
                        'slug': 'article',
                      },
                      'post_type_categories': [],
                      'post_type_sub_categories': [],
                      'is_repost': false,
                      'reposted_post': null,
                      'reposted_by_user': null,
                      'reaction': null,
                    },
                  ],
                },
              },
              'error': null,
            }),
            200,
          );
        }

        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final dashboardProvider = DashboardProvider(
        dashboardLogic: DashboardLogic(
          dashboardApi: DashboardApi(apiClient: apiClient),
          tokenStorage: TokenStorage(),
          networkInfo: networkInfo,
        ),
      );

      await dashboardProvider.loadDashboard(token: 'jwt-token-123');

      expect(dashboardProvider.stories.length, 1);
      expect(dashboardProvider.stories.first.authorName, 'Elisa S');
      expect(dashboardProvider.posts.length, 1);
      expect(dashboardProvider.posts.first.authorName, 'Anna Mary');
      expect(dashboardProvider.hasMorePosts, isTrue);

      await dashboardProvider.loadMorePosts(token: 'jwt-token-123');
      expect(dashboardProvider.posts.length, 2);
      expect(dashboardProvider.hasMorePosts, isFalse);

      dashboardProvider.togglePostLike('p1');
      expect(dashboardProvider.posts.first.isLiked, isTrue);
      expect(dashboardProvider.posts.first.likesCount, 6);

      dashboardProvider.dispose();
    });
  });

  group('LoginScreen UI', () {
    testWidgets('renders Login screen elements and validates empty submit',
        (tester) async {
      final networkInfo = FakeNetworkInfo(connected: true);
      final apiClient = ApiClient(
        networkInfo: networkInfo,
        client: MockClient((_) async => http.Response('{}', 200)),
      );
      final tokenStorage = TokenStorage();
      final authProvider = AuthProvider(
        authLogic: AuthLogic(
          authApi: AuthApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      final dashboardProvider = DashboardProvider(
        dashboardLogic: DashboardLogic(
          dashboardApi: DashboardApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: dashboardProvider),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Log In'), findsNWidgets(2)); // Tab + Button
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot Password ?'), findsOneWidget);
      expect(find.text('Explore without login'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);

      dashboardProvider.dispose();
    });
  });

  group('ProfileProvider, ProfileApi & ProfileScreen', () {
    test('fails with offline error when network is disconnected', () async {
      final networkInfo = FakeNetworkInfo(connected: false);
      final apiClient = ApiClient(
        networkInfo: networkInfo,
        client: MockClient((_) async => http.Response('{}', 200)),
      );
      final profileProvider = ProfileProvider(
        profileLogic: ProfileLogic(
          profileApi: ProfileApi(apiClient: apiClient),
          tokenStorage: TokenStorage(),
          networkInfo: networkInfo,
        ),
      );

      await profileProvider.loadProfile(token: 'jwt-token-123');

      expect(profileProvider.isOfflineError, isTrue);
      expect(profileProvider.profile, isNull);
      expect(profileProvider.errorMessage, isNotNull);

      profileProvider.dispose();
    });

    test('parses GET /api/profile nested data.data response with Bearer JWT',
        () async {
      final networkInfo = FakeNetworkInfo(connected: true);
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/profile');
        expect(request.headers['Authorization'], 'Bearer jwt-token-123');

        return http.Response(
          jsonEncode({
            'success': {'status': true, 'statusCode': 200, 'message': 'OK'},
            'data': {
              'data': {
                'id': 'prof1',
                'user_id': 'u1',
                'first_name': 'Nandhiji',
                'last_name': '',
                'bio': 'Yoga Master | Environmentalist',
                'profile_picture': '',
                'profile_banner': '',
                'gender': 'male',
                'dob': '',
                'age_range': '45-54',
                'opinion_on_counsciouness': 'Awakening daily',
                'professional_bio': 'Yoga Master | Environmentalist',
                'country_code': '+1',
                'phone_no': '(454) 728-0592',
                'email': 'nandhiji@cness.co',
                'address': 'Suite 212, Workafella',
                'country_id': 'c1',
                'state_id': '',
                'personal_vision_statement':
                    'Building spaces for people to learn and connect.',
                'social_links': {'whatsapp': '+14547280592'},
                'communication_sms': true,
                'communication_email': true,
                'communication_whatsapp': false,
                'location': {'city': 'Los Angeles', 'state': 'California'},
                'interests': [
                  {'id': 'i1', 'name': 'Wishing'},
                  {'id': 'i2', 'name': 'Trekking'},
                  {'id': 'i3', 'name': 'Yoga'},
                ],
                'professions': [
                  {'id': 'p1', 'name': 'Designing'},
                  {'id': 'p2', 'name': 'Teacher'},
                ],
                'education': [
                  {
                    'id': 'e1',
                    'degree': 'Business Administration',
                    'institution': 'University of California',
                    'start_date': 'Mar 16',
                    'end_date': 'Apr 18',
                    'location': 'Los Angeles, California',
                    'description': 'Studied organizational leadership.',
                  },
                ],
                'work_experience': [
                  {
                    'id': 'w1',
                    'title': 'Lead Product',
                    'company': 'Cness INC',
                    'start_date': 'Mar 16',
                    'end_date': 'Apr 18',
                    'location': 'Los Angeles, California',
                    'description': 'Developed user flows based on personas.',
                  },
                ],
                'country': {'id': 'c1', 'name': 'United States'},
                'state': null,
                'posts_count': 12,
                'followers_count': 240,
                'following_count': 80,
                'friends_count': 45,
                'mutual_friends_count': 5,
                'identify_uploaded': null,
              },
            },
            'error': null,
          }),
          200,
        );
      });

      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final profileProvider = ProfileProvider(
        profileLogic: ProfileLogic(
          profileApi: ProfileApi(apiClient: apiClient),
          tokenStorage: TokenStorage(),
          networkInfo: networkInfo,
        ),
      );

      await profileProvider.loadProfile(token: 'jwt-token-123');

      expect(profileProvider.errorMessage, isNull);
      expect(profileProvider.profile?.fullName, 'Nandhiji');
      expect(profileProvider.profile?.formattedLocation,
          'Los Angeles, California, United States');
      expect(profileProvider.profile?.interests.length, 3);
      expect(profileProvider.profile?.professions.length, 2);
      expect(profileProvider.profile?.workExperience.first.title, 'Lead Product');
      expect(profileProvider.profile?.education.first.degree,
          'Business Administration');

      profileProvider.dispose();
    });

    testWidgets('ProfileScreen renders fetched profile sections',
        (tester) async {
      final networkInfo = FakeNetworkInfo(connected: true);
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            jsonEncode({
              'success': {'status': true, 'statusCode': 200, 'message': 'OK'},
              'data': {
                'data': {
                  'jwt': 'jwt-token-123',
                  'refresh_token': 'r1',
                  'user': {
                    'id': 'u1',
                    'name': 'Nandhiji',
                    'main_name': 'Nandhiji',
                    'margaret_name': '',
                    'profile_picture': '',
                    'completed_step': 0,
                    'person_organization_complete': 0,
                    'karma_credits': 0,
                    'is_adult': true,
                    'is_seller': false,
                    'is_library': false,
                    'is_disqualify': false,
                  },
                },
              },
              'error': null,
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'success': {'status': true, 'statusCode': 200, 'message': 'OK'},
            'data': {
              'data': {
                'id': 'prof1',
                'user_id': 'u1',
                'first_name': 'Nandhiji',
                'last_name': '',
                'bio': '',
                'profile_picture': '',
                'profile_banner': '',
                'gender': '',
                'dob': '',
                'age_range': '',
                'opinion_on_counsciouness': '',
                'professional_bio': 'Yoga Master | Environmentalist',
                'country_code': '',
                'phone_no': '(454) 728-0592',
                'email': 'nandhiji@cness.co',
                'address': 'Suite 212, Workafella',
                'country_id': '',
                'state_id': '',
                'personal_vision_statement':
                    'Building spaces for people to learn and connect.',
                'social_links': {},
                'communication_sms': true,
                'communication_email': true,
                'communication_whatsapp': false,
                'location': {'city': 'Los Angeles', 'state': 'California'},
                'interests': [
                  {'id': 'i1', 'name': 'Yoga'},
                ],
                'professions': [
                  {'id': 'p1', 'name': 'Teacher'},
                ],
                'education': [],
                'work_experience': [],
                'country': {'id': 'c1', 'name': 'United States'},
                'state': null,
                'posts_count': 4,
                'followers_count': 12,
                'following_count': 8,
                'friends_count': 3,
                'mutual_friends_count': 0,
                'identify_uploaded': null,
              },
            },
            'error': null,
          }),
          200,
        );
      });

      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final tokenStorage = TokenStorage();
      final authProvider = AuthProvider(
        authLogic: AuthLogic(
          authApi: AuthApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      await authProvider.login(
        email: 'nandhiji@cness.co',
        password: 'password123',
      );

      final dashboardProvider = DashboardProvider(
        dashboardLogic: DashboardLogic(
          dashboardApi: DashboardApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      final profileProvider = ProfileProvider(
        profileLogic: ProfileLogic(
          profileApi: ProfileApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: dashboardProvider),
            ChangeNotifierProvider.value(value: profileProvider),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nandhiji'), findsOneWidget);
      expect(find.text('Yoga Master | Environmentalist'), findsOneWidget);
      expect(find.text('Basic Info'), findsOneWidget);
      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget);
      expect(find.text('nandhiji@cness.co'), findsOneWidget);
      expect(find.text('Suite 212, Workafella'), findsOneWidget);

      dashboardProvider.dispose();
      profileProvider.dispose();
    });

    testWidgets('ProfileScreen Back button pops back to previous route',
        (tester) async {
      final networkInfo = FakeNetworkInfo(connected: true);
      final mockClient = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': {'status': false, 'statusCode': 401, 'message': 'Expired'},
            'data': null,
            'error': {'message': 'Session Expire!'},
          }),
          401,
        ),
      );
      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final tokenStorage = TokenStorage();
      final authProvider = AuthProvider(
        authLogic: AuthLogic(
          authApi: AuthApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      final dashboardProvider = DashboardProvider(
        dashboardLogic: DashboardLogic(
          dashboardApi: DashboardApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      final profileProvider = ProfileProvider(
        profileLogic: ProfileLogic(
          profileApi: ProfileApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: dashboardProvider),
            ChangeNotifierProvider.value(value: profileProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: const Text('Open Profile'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsNothing);
      expect(find.text('Open Profile'), findsOneWidget);

      dashboardProvider.dispose();
      profileProvider.dispose();
    });

    testWidgets(
        'ProfileScreen shows only one session expired banner when cached profile exists and refresh returns 401',
        (tester) async {
      final networkInfo = FakeNetworkInfo(connected: true);
      var callCount = 0;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            jsonEncode({
              'success': {'status': true, 'statusCode': 200, 'message': 'OK'},
              'data': {
                'data': {
                  'jwt': 'jwt-token-123',
                  'refresh_token': 'r1',
                  'user': {
                    'id': 'u1',
                    'name': 'Meikannan',
                    'main_name': 'Meikannan',
                    'margaret_name': '',
                    'profile_picture': '',
                    'completed_step': 0,
                    'person_organization_complete': 0,
                    'karma_credits': 0,
                    'is_adult': true,
                    'is_seller': false,
                    'is_library': false,
                    'is_disqualify': false,
                  },
                },
              },
              'error': null,
            }),
            200,
          );
        }

        callCount += 1;
        if (callCount == 1) {
          return http.Response(
            jsonEncode({
              'success': {'status': true, 'statusCode': 200, 'message': 'OK'},
              'data': {
                'data': {
                  'id': 'prof1',
                  'user_id': 'u1',
                  'first_name': 'Meikannan',
                  'last_name': 'Krishnamoorthy',
                  'bio': '',
                  'profile_picture': '',
                  'profile_banner': '',
                  'gender': '',
                  'dob': '',
                  'age_range': '',
                  'opinion_on_counsciouness': '',
                  'professional_bio': '',
                  'country_code': '+34',
                  'phone_no': '545 45 45 54',
                  'email': 'meikannan@cness.co',
                  'address': 'Udagawacho',
                  'country_id': '',
                  'state_id': '',
                  'personal_vision_statement': '',
                  'social_links': <String, dynamic>{},
                  'communication_sms': true,
                  'communication_email': true,
                  'communication_whatsapp': false,
                  'location': {'city': 'Shibuya'},
                  'interests': <dynamic>[],
                  'professions': <dynamic>[],
                  'education': <dynamic>[],
                  'work_experience': <dynamic>[],
                  'country': null,
                  'state': null,
                  'posts_count': 0,
                  'followers_count': 0,
                  'following_count': 0,
                  'friends_count': 0,
                  'mutual_friends_count': 0,
                  'identify_uploaded': null,
                },
              },
              'error': null,
            }),
            200,
          );
        }

        return http.Response(
          jsonEncode({
            'success': {'status': false, 'statusCode': 401, 'message': 'Expired'},
            'data': null,
            'error': {'message': 'Session Expire!'},
          }),
          401,
        );
      });

      final apiClient = ApiClient(networkInfo: networkInfo, client: mockClient);
      final tokenStorage = TokenStorage();
      final authProvider = AuthProvider(
        authLogic: AuthLogic(
          authApi: AuthApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      await authProvider.login(email: 'a@b.com', password: 'password');

      final dashboardProvider = DashboardProvider(
        dashboardLogic: DashboardLogic(
          dashboardApi: DashboardApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      final profileProvider = ProfileProvider(
        profileLogic: ProfileLogic(
          profileApi: ProfileApi(apiClient: apiClient),
          tokenStorage: tokenStorage,
          networkInfo: networkInfo,
        ),
      );
      await profileProvider.loadProfile(token: authProvider.activeToken);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: dashboardProvider),
            ChangeNotifierProvider.value(value: profileProvider),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session expired. Please log in again.'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Session Expire!'), findsNothing);

      dashboardProvider.dispose();
      profileProvider.dispose();
    });

    testWidgets(
        'PostCardWidget popup menu displays all 5 options and triggers callbacks',
        (tester) async {
      final post = PostModel.fromJson({
        'id': 'p-menu-1',
        'user_id': 'u3',
        'content': 'Mindfulness reflection',
        'createdAt': '2026-11-12T08:00:00Z',
        'user': {'id': 'u3', 'username': 'annamary'},
        'profile': {'id': 'pr1', 'user_id': 'u3', 'first_name': 'Anna', 'last_name': 'Mary'},
      });

      var copied = false;
      var saved = false;
      var shared = false;
      var reported = false;
      var notInterested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCardWidget(
              post: post,
              onLikeTap: () {},
              onSaveTap: () => saved = true,
              onShareTap: () => shared = true,
              onCopyLinkTap: () => copied = true,
              onReportTap: () => reported = true,
              onNotInterestedTap: () => notInterested = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Copy post link'), findsOneWidget);
      expect(find.text('Save this post'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(find.text('Not interested'), findsOneWidget);

      await tester.tap(find.text('Copy post link'));
      await tester.pumpAndSettle();
      expect(copied, isTrue);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save this post'));
      await tester.pumpAndSettle();
      expect(saved, isTrue);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(shared, isTrue);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      expect(reported, isTrue);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not interested'));
      await tester.pumpAndSettle();
      expect(notInterested, isTrue);
    });
  });
}
