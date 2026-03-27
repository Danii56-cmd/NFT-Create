import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/view/auth_screens.dart/update_pass_screens/update_pass_screen2.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';
import 'package:nft_create/widgets/customtextformfield.dart';

class UpdatePasswordScreen1 extends StatefulWidget {
  final String otp;
  UpdatePasswordScreen1({super.key, required this.otp});

  @override
  State<UpdatePasswordScreen1> createState() => _UpdatePasswordScreen1State();
}

class _UpdatePasswordScreen1State extends State<UpdatePasswordScreen1> {
  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {});
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
              "UPDATE PASSWORD",
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
                    "Please enter a minimum 8 characters long secure and strong password.",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 40.h),
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
                  SizedBox(height: 20.h),
                  CustomTextFormField(
                    hintText: "Confirm new password",
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
                  SizedBox(height: 300.h),
                  Custombutton(
                    text: "Update Password",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdatePasswordScreen2(),
                        ),
                      );
                    },
                    height: 60.h,
                    width: 370.w,
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
