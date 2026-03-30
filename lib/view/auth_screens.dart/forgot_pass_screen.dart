import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/view/auth_screens.dart/update_pass_screens/update_pass_screen1.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';

class ForgotPasswordScreen1 extends StatefulWidget {
  final String otp;

  ForgotPasswordScreen1({super.key, required this.otp});

  @override
  State<ForgotPasswordScreen1> createState() => _ForgotPasswordScreen1State();
}

class _ForgotPasswordScreen1State extends State<ForgotPasswordScreen1> {
  final TextEditingController otpbox1 = TextEditingController();
  final TextEditingController otpbox2 = TextEditingController();
  final TextEditingController otpbox3 = TextEditingController();
  final TextEditingController otpbox4 = TextEditingController();

  final FocusNode f1 = FocusNode();
  final FocusNode f2 = FocusNode();
  final FocusNode f3 = FocusNode();
  final FocusNode f4 = FocusNode();

  bool _isVerifying = false;
  bool isNavigated = false;

  @override
  void dispose() {
    otpbox1.dispose();
    otpbox2.dispose();
    otpbox3.dispose();
    otpbox4.dispose();
    f1.dispose();
    f2.dispose();
    f3.dispose();
    f4.dispose();
    super.dispose();
  }

  Widget otpInputBox({
    required TextEditingController controller,
    required FocusNode currentFocus,
    FocusNode? nextFocus,
    FocusNode? prevFocus,
  }) {
    return SizedBox(
      height: 68.h,
      width: 60.w,
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          color: Colors.black,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        cursorColor: AppConstants.Primary,
        decoration: InputDecoration(
          counterText: "",
          hintText: "•",
          filled: true,
          fillColor: AppConstants.Secondary,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 35.sp,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppConstants.Primary, width: 2.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppConstants.Primary, width: 2.w),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            nextFocus?.requestFocus();
          } else {
            prevFocus?.requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  void verifyOTP() {
    if (otpbox1.text.isEmpty ||
        otpbox2.text.isEmpty ||
        otpbox3.text.isEmpty ||
        otpbox4.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all 4 digits")),
      );
      return;
    }
    if (!isNavigated) {
      setState(() => _isVerifying = true);
      isNavigated = true;

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isVerifying = false);
        String otp = otpbox1.text + otpbox2.text + otpbox3.text + otpbox4.text;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdatePasswordScreen1(otp: otp),
          ),
        ).then((_) {
          isNavigated = false;
          otpbox1.clear();
          otpbox2.clear();
          otpbox3.clear();
          otpbox4.clear();
          f1.requestFocus();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "FORGOT PASSWORD",
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
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppConstants.Secondary,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      otpInputBox(
                        controller: otpbox1,
                        currentFocus: f1,
                        nextFocus: f2,
                      ),
                      SizedBox(width: 10.w),
                      otpInputBox(
                        controller: otpbox2,
                        currentFocus: f2,
                        nextFocus: f3,
                        prevFocus: f1,
                      ),
                      SizedBox(width: 10.w),
                      otpInputBox(
                        controller: otpbox3,
                        currentFocus: f3,
                        nextFocus: f4,
                        prevFocus: f2,
                      ),
                      SizedBox(width: 10.w),
                      otpInputBox(
                        controller: otpbox4,
                        currentFocus: f4,
                        prevFocus: f3,
                      ),
                    ],
                  ),
                  SizedBox(height: 70.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Resend code ",
                          style: TextStyle(
                            color: AppConstants.Primary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Text(
                        "in 29 seconds",
                        style: TextStyle(
                          color: AppConstants.Secondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 70.h),
                  _isVerifying
                      ? Column(
                          children: [
                            SpinKitCircle(
                              color: AppConstants.Primary,
                              size: 50.sp,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              "Verifying...",
                              style: TextStyle(
                                color: AppConstants.Secondary,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        )
                      : SizedBox(height: 0),
                  SizedBox(height: 200.h),
                  _isVerifying
                      ? SizedBox(height: 0)
                      : Custombutton(
                          text: "Verify",
                          height: 60.h,
                          width: 370.w,
                          onPressed: verifyOTP,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: AppConstants.Secondary,
                          ),
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
