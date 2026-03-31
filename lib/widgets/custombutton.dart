import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';

class Custombutton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double width;
  final Widget? icon;

  const Custombutton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.height,
    required this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: 17.w),
            Text(
              text,
              style: TextStyle(
                color: AppConstants.Secondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (icon != null) icon! else SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
