import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget tabItem(String text, bool active) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.h),
    child: Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: active ? Colors.orange : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 5),
            height: 2,
            width: 40,
            color: Colors.orange,
          ),
      ],
    ),
  );
}
