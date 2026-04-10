import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/view/homescreen.dart';
import 'package:nft_create/view/onboarding_screens/onboarding_mainscreen.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const String keyLogin = "Login";
  @override
  void initState() {
    super.initState();

    // Rotation animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(); // keeps rotating

    // Timer for navigation
    whereTOGO();
  }

  @override
  void dispose() {
    _controller.dispose(); // important
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.black38,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔄 Rotating CircleAvatar
              RotationTransition(
                turns: _controller,
                child: CircleAvatar(
                  radius: 150.r,
                  backgroundColor: AppConstants.Primary,
                  backgroundImage: AssetImage(AppConstants.Logo),
                ),
              ),

              SizedBox(height: 50.h),

              Text(
                "NFT",
                style: TextStyle(
                  color: AppConstants.Secondary,
                  fontSize: 50.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void whereTOGO() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(keyLogin);
    Timer(Duration(seconds: 2), () {
      if (isLoggedIn != null) {
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingMain()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingMain()),
        );
      }
    });
  }
}
