import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      textAlign: TextAlign.center,
      cursorColor: Colors.orange[700],
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0.r),
          borderSide: BorderSide(color: Colors.orange[700]!, width: 2.0.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0.r),
          borderSide: BorderSide(color: Colors.orange[700]!, width: 2.0.w),
        ),
      ),
    );
  }
}
