import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';

Widget tabItem(String text, bool active) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.h),
    child: Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: active ? AppConstants.Primary : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (active)
          Container(
            margin: EdgeInsets.only(top: 5.h),
            height: 2.h,
            width: 40.w,
            color: AppConstants.Primary,
          ),
      ],
    ),
  );
}
