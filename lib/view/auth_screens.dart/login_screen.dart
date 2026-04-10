import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/services/auth_service.dart';
import 'package:nft_create/view/auth_screens.dart/signup_screen.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';
import 'package:nft_create/widgets/customtextformfield.dart';
import 'package:nft_create/widgets/main_screen.dart'; // Your MainScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _authService.login(email, password);

    setState(() => _isLoading = false);

    if (success) {
      // Navigate to Main Screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                  SizedBox(height: 30.h),

                  // Email Field
                  CustomTextFormField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    prefixIcon: Icon(
                      Icons.email,
                      color: AppConstants.Primary,
                      size: 20.sp,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 20.h),

                  // Password Field
                  CustomTextFormField(
                    controller: _passwordController,
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
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    obscureText: _obscurePassword,
                  ),

                  SizedBox(height: 10.h),

                  // Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Add forgot password logic later
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Forgot password coming soon"),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot the password?",
                          style: TextStyle(
                            color: AppConstants.Secondary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 50.h),

                  // Login Button
                  Custombutton(
                    text: _isLoading ? "Logging in..." : "Login",
                    onPressed: _handleLogin,
                    height: 60.h,
                    width: 370.w,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              color: AppConstants.Secondary,
                              strokeWidth: 2.w,
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            color: AppConstants.Secondary,
                            size: 20.sp,
                          ),
                  ),

                  SizedBox(height: 30.h),

                  // Sign Up Link
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
                              builder: (context) => const SignupScreen(),
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

                  SizedBox(height: 40.h),

                  // Google Login Button
                  SizedBox(
                    height: 60.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add Google Sign-In later
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Google Sign-In coming soon"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.Secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: AppConstants.Primary,
                            width: 1.w,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(AppConstants.Google),
                            height: 22.h,
                            width: 22.w,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "Login with Google",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
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
