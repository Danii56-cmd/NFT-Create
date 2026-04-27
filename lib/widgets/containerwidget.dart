import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';

class containerWidget extends StatelessWidget {
  final String image;
  final String text;
  const containerWidget({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 75.h,
        width: 78.w,
        decoration: BoxDecoration( 
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.transparent,
          border: Border.all(color: AppConstants.Primary),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.transparent,
              child: Image.asset(image, height: 20.h, width: 20.w),
            ),
            Text(
              text,
              style: TextStyle(color: AppConstants.Secondary, fontSize: 10.sp),
            ),
          ],
        ),
      ),
    );
  }
}
