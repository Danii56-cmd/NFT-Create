import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';
import 'package:nft_create/widgets/exchange_listview.dart';

class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black38,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppConstants.Secondary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: Text(
                'Currency Exchange',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 330.h,
                    width: double.infinity,
                    color: Colors.transparent,
                  ),
                  Container(
                    height: 300.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // color: AppConstants.Primary,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent, // Top remains transparent
                          Colors.transparent,
                          Colors.transparent, // Transition point
                          AppConstants.Primary.withOpacity(
                            0.5,
                          ), // Solid color for the bottom part
                        ],
                        // The "0.4" determines the horizontal line position
                        stops: [0.3, 0.3, 0.3, 1.0],
                      ),

                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(80.r),
                        bottomRight: Radius.circular(80.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "USD",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              Spacer(),
                              Container(
                                height: 30.h,
                                width: 70.w,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(08.r),
                                  border: Border.all(
                                    color: AppConstants.Primary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "-100",
                                    style: TextStyle(
                                      color: AppConstants.Secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Balance: 2000",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            children: [
                              SizedBox(
                                width: 100.w,
                                child: Divider(
                                  color: AppConstants.Primary,
                                  // thickness: 1,
                                  height: 30.h,
                                  // endIndent: 50.r,
                                  // indent: 50.r,
                                ),
                              ),
                              Container(
                                height: 30.h,
                                width: 110.w,
                                decoration: BoxDecoration(
                                  color: AppConstants.Secondary,
                                  borderRadius: BorderRadius.circular(08.r),
                                  border: Border.all(
                                    color: AppConstants.Primary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "1 USD = 278 PKR",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100.w,
                                child: Divider(
                                  color: AppConstants.Primary,
                                  // thickness: 1,
                                  height: 30.h,
                                  // endIndent: 50.r,
                                  // indent: 50.r,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "PKR",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              Spacer(),
                              Container(
                                height: 30.h,
                                width: 70.w,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(08.r),
                                  border: Border.all(
                                    color: AppConstants.Primary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "-100",
                                    style: TextStyle(
                                      color: AppConstants.Secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Balance: 0",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 270.h,
                    left: 110.w,
                    child: Custombutton(
                      text: 'Exchange',
                      onPressed: () {},
                      height: 70,
                      width: 270,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  children: [
                    Text(
                      "History",
                      style: TextStyle(
                        color: AppConstants.Secondary,
                        fontSize: 20,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "All",
                      style: TextStyle(
                        color: AppConstants.Secondary,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: ExchangeListView()),
            ],
          ),
        ),
      ),
    );
  }
}
