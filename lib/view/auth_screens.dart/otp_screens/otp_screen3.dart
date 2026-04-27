import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/widgets/app_background.dart';

class OTPScreen3 extends StatelessWidget {
  final String otp;

  const OTPScreen3({super.key, required this.otp});

  Widget otpBox(String number) {
    return Container(
      height: 68.h,
      width: 60.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppConstants.Primary, width: 2),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
            title: Text(
              "OTP Verification",
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  Text(
                    "Please enter 4 digits OTP code we sent to your mobile number.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      otpBox(otp[0]),
                      SizedBox(width: 10.w),
                      otpBox(otp[1]),
                      SizedBox(width: 10.w),
                      otpBox(otp[2]),
                      SizedBox(width: 10.w),
                      otpBox(otp[3]),
                    ],
                  ),
                  SizedBox(height: 80.h),
                  Icon(
                    Icons.verified,
                    color: AppConstants.Primary,
                    size: 80.sp,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Account created Successfully",
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
