import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';

class ExchangeListView extends StatelessWidget {
  const ExchangeListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          height: 80.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppConstants.Primary),
          ),
          child: Row(
            children: [
              // 🔵 Currency Circles
              const CurrencyCircles(),

              SizedBox(width: 30.w),

              // 📝 Middle Text (Expands)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "USD",
                      style: TextStyle(
                        color: AppConstants.Secondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "250",
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        AppConstants.Exchange,
                        height: 20.h,
                        width: 20.w,
                      ),
                    ),
                    Text(
                      "30-03-2026",
                      style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 40.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PKR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "66,590",
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),

              // // 💰 Price (Right Side)
              // Padding(
              //   padding: EdgeInsets.only(right: 10.w),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         "278.50",
              //         style: TextStyle(
              //           color: AppConstants.Primary,
              //           fontSize: 14.sp,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       SizedBox(height: 4.h),
              //       Icon(
              //         Icons.arrow_forward_ios,
              //         size: 14.sp,
              //         color: Colors.white,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}

class CurrencyCircles extends StatelessWidget {
  const CurrencyCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: double.infinity,
      child: Stack(
        children: [
          // 💵 USD Circle
          Positioned(
            left: 10.w,
            top: 15.h,
            child: Container(
              height: 50.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: AppConstants.Primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "\$",
                  style: TextStyle(
                    color: AppConstants.Secondary,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
          ),

          // 🇵🇰 PKR Circle
          Positioned(
            left: 45.w,
            top: 15.h,
            child: Container(
              height: 50.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: AppConstants.Secondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "RS",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
