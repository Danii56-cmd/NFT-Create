import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/view/auth_screens.dart/otp_screens/otp_screen2.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';

class OTPScreen1 extends StatefulWidget {
  const OTPScreen1({super.key});

  @override
  State<OTPScreen1> createState() => _OTPScreen1State();
}

class _OTPScreen1State extends State<OTPScreen1> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  bool isNavigated = false;

  void checkOTP() {
    setState(() {});
  }

  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final FocusNode _focus3 = FocusNode();
  final FocusNode _focus4 = FocusNode();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    super.dispose();
  }

  Widget otpBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    FocusNode? prevFocus,
  }) {
    return SizedBox(
      height: 68.h,
      width: 60.w,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

          checkOTP();
          setState(() {});
        },
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
              icon: Icon(Icons.arrow_back_ios, color: AppConstants.Secondary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: Text(
                "OTP Verification",
                style: TextStyle(
                  color: AppConstants.Secondary,
                  fontSize: 20.sp,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text(
                    "Enter the 4-digit code sent to your mobile number.",
                    style: TextStyle(
                      color: AppConstants.Secondary,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      otpBox(
                        controller: _controller1,
                        focusNode: _focus1,
                        nextFocus: _focus2,
                      ),
                      SizedBox(width: 10.w),
                      otpBox(
                        controller: _controller2,
                        focusNode: _focus2,
                        nextFocus: _focus3,
                        prevFocus: _focus1,
                      ),
                      SizedBox(width: 10.w),
                      otpBox(
                        controller: _controller3,
                        focusNode: _focus3,
                        nextFocus: _focus4,
                        prevFocus: _focus2,
                      ),
                      SizedBox(width: 10.w),
                      otpBox(
                        controller: _controller4,
                        focusNode: _focus4,
                        prevFocus: _focus3,
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
                  SizedBox(height: 260.w),
                  Custombutton(
                    text: "Verify",
                    onPressed: () {
                      if (!isNavigated &&
                          _controller1.text.isNotEmpty &&
                          _controller2.text.isNotEmpty &&
                          _controller3.text.isNotEmpty &&
                          _controller4.text.isNotEmpty) {
                        isNavigated = true;

                        String otp =
                            _controller1.text +
                            _controller2.text +
                            _controller3.text +
                            _controller4.text;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OTPScreen2(otp: otp),
                          ),
                        ).then((_) {
                          isNavigated = false;
                          _controller1.clear();
                          _controller2.clear();
                          _controller3.clear();
                          _controller4.clear();
                          _focus1.requestFocus();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter all 4 digits")),
                        );
                      }
                    },
                    height: 60.h,
                    width: 370.w,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppConstants.Secondary,
                      size: 20.sp,
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
