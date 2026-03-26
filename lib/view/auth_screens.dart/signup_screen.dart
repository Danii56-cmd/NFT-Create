import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';
import 'package:nft_create/widgets/customtextformfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
                  Image(image: AssetImage("assets/images/LOGO.png")),
                  Text(
                    "NFT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0.h),

                  CustomTextFormField(
                    hintText: "Enter your email",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.orange[700],
                      size: 20.sp,
                    ),
                    suffixIcon: const SizedBox.shrink(),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 20.0.h),

                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      IntlPhoneField(
                        textAlign: TextAlign.center,
                        cursorColor: Colors.orange[700],
                        initialCountryCode: 'PK',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                        decoration: InputDecoration(
                          hintText: 'Mobile number',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 100.w,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: Colors.orange[700]!,
                              width: 2.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: Colors.orange[700]!,
                              width: 2.w,
                            ),
                          ),
                        ),
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.orange[700],
                        ),
                        onChanged: (phone) {},
                      ),
                      Positioned(
                        right: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          color: Colors.transparent, // dummy icon space
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.0.h),

                  CustomTextFormField(
                    hintText: "Enter your password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.orange[700],
                      size: 20.sp,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.orange[700],
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

                  SizedBox(height: 30.0.h),

                  // ── Fixed: Use Custombutton here ──
                  Custombutton(
                    text: "Signup",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => OTPScreen1()),
                      // );
                    },
                    height: 60.h,
                    width: 370.w,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),

                  SizedBox(height: 20.0.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 3.r,
                        backgroundColor: Colors.orange[700],
                      ),
                      Container(
                        width: 100.w,
                        height: 2.h,
                        color: Colors.orange[700],
                      ),
                      SizedBox(width: 20.0.w),
                      Text(
                        "or signup with",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                      SizedBox(width: 20.0.w),
                      Container(
                        width: 92.w,
                        height: 02.h,

                        color: Colors.orange[700],
                      ),
                      CircleAvatar(
                        radius: 3.r,
                        backgroundColor: Colors.orange[700],
                      ),
                    ],
                  ),

                  SizedBox(height: 30.0.h),

                  SizedBox(
                    height: 60.0.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: Colors.orange[700]!,
                            width: 1.0.w,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image(
                            image: AssetImage("assets/images/google.png"),
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            "Signup with Google",
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.0.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
