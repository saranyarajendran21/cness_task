import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/storage/token_storage.dart';
import 'data/api/auth_api.dart';
import 'data/api/dashboard_api.dart';
import 'data/api/profile_api.dart';
import 'logic/auth_logic.dart';
import 'logic/dashboard_logic.dart';
import 'logic/profile_logic.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/profile_provider.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final networkInfo = NetworkInfoImpl();
  final apiClient = ApiClient(networkInfo: networkInfo);
  final tokenStorage = TokenStorage();

  final authApi = AuthApi(apiClient: apiClient);
  final dashboardApi = DashboardApi(apiClient: apiClient);
  final profileApi = ProfileApi(apiClient: apiClient);

  final authLogic = AuthLogic(
    authApi: authApi,
    tokenStorage: tokenStorage,
    networkInfo: networkInfo,
  );
  final dashboardLogic = DashboardLogic(
    dashboardApi: dashboardApi,
    tokenStorage: tokenStorage,
    networkInfo: networkInfo,
  );
  final profileLogic = ProfileLogic(
    profileApi: profileApi,
    tokenStorage: tokenStorage,
    networkInfo: networkInfo,
  );

  runApp(
    CnessApp(
      authLogic: authLogic,
      dashboardLogic: dashboardLogic,
      profileLogic: profileLogic,
    ),
  );
}

class CnessApp extends StatelessWidget {
  const CnessApp({
    super.key,
    required this.authLogic,
    required this.dashboardLogic,
    required this.profileLogic,
  });

  final AuthLogic authLogic;
  final DashboardLogic dashboardLogic;
  final ProfileLogic profileLogic;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authLogic: authLogic)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(dashboardLogic: dashboardLogic),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileLogic: profileLogic),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
          scaffoldBackgroundColor: AppColors.scaffoldBg,
          useMaterial3: true,
        ),
        home: const _AppEntryGate(),
      ),
    );
  }
}

class _AppEntryGate extends StatelessWidget {
  const _AppEntryGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const Scaffold(
        backgroundColor: AppColors.headerDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
