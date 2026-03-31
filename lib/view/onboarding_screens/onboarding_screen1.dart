import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
// import 'package:nft_create/view/onboarding_screens/onboarding_screen2.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';

class OnboardingScreen1 extends StatelessWidget {
  final VoidCallback onNext;
  const OnboardingScreen1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.black38,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(height: 340.h, color: Colors.transparent),
                  Container(
                    height: 280.h,
                    decoration: BoxDecoration(
                      color: AppConstants.Primary,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(110.r),
                        bottomLeft: Radius.circular(110.r),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200.h,
                    left: 127.w,
                    child: CircleAvatar(
                      radius: 80.r,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(AppConstants.Logo),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 05.h),
              Text(
                "NFT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 130.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  "Find rare and trending NFT's with powerful\nsearch tools",
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
              //     CircleAvatar(
              //       radius: 09.r,
              //       backgroundColor: Colors.white,
              //       child: CircleAvatar(
              //         radius: 8.r,
              //         backgroundColor: Colors.orange[700],
              //       ),
              //     ),
              //     SizedBox(width: 5.w),
              //     CircleAvatar(radius: 8.r, backgroundColor: Colors.white),
              //     SizedBox(width: 5.w),
              //     CircleAvatar(radius: 8.r, backgroundColor: Colors.white),
              //   ],
              // ),
              SizedBox(height: 25.h),
              Custombutton(
                height: 60.h,
                width: 380.h,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20.sp,
                ),
                text: "Continue",
                onPressed: onNext,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
