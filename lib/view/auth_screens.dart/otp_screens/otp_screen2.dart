import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/view/auth_screens.dart/otp_screens/otp_screen3.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/otp_box.dart';

class OTPScreen2 extends StatefulWidget {
  final String otp;

  const OTPScreen2({super.key, required this.otp});

  @override
  State<OTPScreen2> createState() => _OTPScreen2State();
}

class _OTPScreen2State extends State<OTPScreen2> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OTPScreen3(otp: widget.otp)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final otpbox1 = TextEditingController();
    final otpbox2 = TextEditingController();
    final otpbox3 = TextEditingController();
    final otpbox4 = TextEditingController();
    return AppBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "OTP Verification",
              style: TextStyle(color: AppConstants.Secondary, fontSize: 20.sp),
            ),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppConstants.Secondary),
              onPressed: () => Navigator.pop(context),
            ),
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
                    style: TextStyle(
                      color: AppConstants.Secondary,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      otpInputBox(controller: otpbox1),
                      SizedBox(width: 10.w),
                      otpInputBox(controller: otpbox2),
                      SizedBox(width: 10.w),
                      otpInputBox(controller: otpbox3),
                      SizedBox(width: 10.w),
                      otpInputBox(controller: otpbox4),
                    ],
                  ),
                  SizedBox(height: 80.h),
                  SpinKitCircle(color: AppConstants.Primary, size: 50.sp),
                  SizedBox(height: 20.h),
                  Text(
                    "Verifying...",
                    style: TextStyle(
                      color: AppConstants.Secondary,
                      fontSize: 16.sp,
                    ),
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
