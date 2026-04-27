import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget otpInputBox({required TextEditingController controller}) {
  return Container(
    height: 68.h,
    width: 60.w,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: Colors.orange, width: 2),
    ),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: const InputDecoration(
        counterText: "",
        border: InputBorder.none,
      ),
      onChanged: (value) {
        if (value.length == 1) {
          FocusScope.of(controller.context!).nextFocus();
        }
      },
    ),
  );
}

extension on TextEditingController {
  get context => null;
}
