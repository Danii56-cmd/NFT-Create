import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nft_create/services/auth_service.dart';
<<<<<<< HEAD
import 'package:nft_create/view/auth_screens.dart/login_screen.dart';
=======
// import 'package:nft_create/view/auth_screens.dart/login_screen.dart';
import 'package:nft_create/view/onboarding_screens/onboarding_mainscreen.dart';
// import 'package:nft_create/view/onboarding_screens/splash_screen.dart';
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
import 'package:nft_create/widgets/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:nft_create/providers/nft_creator_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // await Hive.openBox('nfts');
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 780),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NFTCreatorProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NFT App',
<<<<<<< HEAD
            home: const AuthWrapper(),
=======
            home: AuthWrapper(),
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    // If user is logged in → go to main app flow
    if (_isLoggedIn) {
      return const MainScreen(); // or MainScreen() if you prefer
    }

    // Otherwise show Login Screen
<<<<<<< HEAD
    return const LoginScreen();
=======
    return const OnboardingMain();
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  }
}
