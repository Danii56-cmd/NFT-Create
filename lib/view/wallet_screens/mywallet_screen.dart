import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/containerwidget.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.black38,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.r), // Border thickness
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.Primary, // Border color
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(AppConstants.User),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "CODEXDEV",
                      style: TextStyle(fontSize: 20.sp, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Stack(
                  children: [
                    Container(
                      height: 170.h,
                      width: 340.w,
                      decoration: BoxDecoration(
                        // image: DecorationImage(
                        //   image: AssetImage("assets/images/background.png"),
                        //   fit: BoxFit.cover,
                        // ),
                        borderRadius: BorderRadius.circular(30.r),
                        color: AppConstants.Primary,
                      ),
                    ),
                    Positioned(
                      bottom: 10.h,
                      right: 10.w,
                      child: IconButton(
                        color: AppConstants.Primary,
                        iconSize: 30.sp,
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black),
                        ),
                        onPressed: () {},
                        icon: Icon(Icons.add),
                      ),
                    ),
                    Positioned(
                      top: 20.h,
                      left: 15.w,
                      child: Text(
                        "Your Balance",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50.h,
                      left: 15.w,
                      child: Text(
                        "PKR 750,000",
                        style: TextStyle(fontSize: 20.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    containerWidget(
                      image: AppConstants.Exchange,
                      text: "EXCHANGE",
                    ),
                    containerWidget(
                      image: AppConstants.Deposit,
                      text: "DEPOSIT",
                    ),
                    containerWidget(
                      image: AppConstants.Withdraw,
                      text: "WITHDRAW",
                    ),
                    containerWidget(
                      image: AppConstants.Withdraw,
                      text: "HISTORY",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
