import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
// import 'package:nft_create/view/auth_screens.dart/forgot_pass_screen.dart';
import 'package:nft_create/view/auth_screens.dart/signup_screen.dart';
// import 'package:nft_create/view/homescreen.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';
import 'package:nft_create/widgets/customtextformfield.dart';
import 'package:nft_create/widgets/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black38,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage(AppConstants.Logo)),
                  Text(
                    "NFT",
                    style: TextStyle(
                      color: AppConstants.Secondary,
                      fontSize: 50.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                  CustomTextFormField(
                    hintText: "Enter your email",
                    prefixIcon: Icon(
                      Icons.email,
                      color: AppConstants.Primary,
                      size: 20.sp,
                    ),
                    suffixIcon: const SizedBox.shrink(),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.0.h),
                  CustomTextFormField(
                    hintText: "Enter your password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: AppConstants.Primary,
                      size: 20.sp,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppConstants.Primary,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    obscureText: _obscurePassword,
                  ),
                  SizedBox(height: 10.0.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 05.0),
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         ForgotPasswordScreen1(otp: ''),
                            //   ),
                            // );
                          },

                          child: Text(
                            "Forgot the password?",
                            style: TextStyle(
                              color: AppConstants.Secondary,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60.0.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppConstants.Secondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppConstants.Primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0.h),

                  // lib/view/login_screen/login_screen.dart
                  Custombutton(
                    text: "Login",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    },
                    height: 60.h,
                    width: 370.w,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppConstants.Secondary,
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                  SizedBox(
                    height: 60.0.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.Secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: AppConstants.Primary,
                            width: 1.0.w,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image(
                            image: AssetImage(AppConstants.Google),
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(width: 75.w),
                          Text(
                            "Login with Google",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
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
