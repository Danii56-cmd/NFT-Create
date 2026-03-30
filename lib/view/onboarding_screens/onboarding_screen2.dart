import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/view/auth_screens.dart/login_screen.dart';
// import 'package:nft_create/view/onboarding_screens/onboarding_screen3.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';

class OnboardingScreen2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const OnboardingScreen2({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black38,
          body: Padding(
            padding: EdgeInsets.only(top: 50.0.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0.w, right: 10.0.w),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Image(
                    image: AssetImage("assets/images/image1.png"),
                    height: 300.h,
                  ),
                  SizedBox(height: 110.h),
                  Center(
                    child: Text(
                      "Turn your passion into profit.\nBuy, sell and trade NFT's securely",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 70.h),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     CircleAvatar(radius: 08.r, backgroundColor: Colors.white),
                  //     SizedBox(width: 05.w),
                  //     CircleAvatar(
                  //       radius: 09.r,
                  //       backgroundColor: Colors.white,
                  //       child: CircleAvatar(
                  //         radius: 08.r,
                  //         backgroundColor: Colors.orange[700],
                  //       ),
                  //     ),
                  //     SizedBox(width: 05.w),
                  //     CircleAvatar(radius: 08.r, backgroundColor: Colors.white),
                  //   ],
                  // ),
                  SizedBox(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Custombutton(
                        height: 60.h,
                        width: 150.w,
                        text: "Back",
                        onPressed: onBack,
                      ),
                      Custombutton(
                        height: 60.h,
                        width: 150.w,
                        text: "Next",
                        onPressed: onNext,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
