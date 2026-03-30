import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/view/auth_screens.dart/login_screen.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';

class UpdatePasswordScreen2 extends StatelessWidget {
  const UpdatePasswordScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.all(20.h),
            child: Column(
              children: [
                Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      color: AppConstants.Primary,
                      size: 80.sp,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Password Updated Successfully",
                      style: TextStyle(
                        color: AppConstants.Secondary,
                        fontSize: 18.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Spacer(),
                Custombutton(
                  text: "Continue",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  height: 60.h,
                  width: double.infinity,
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
    );
  }
}
