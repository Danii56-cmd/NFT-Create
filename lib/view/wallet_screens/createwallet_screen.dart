import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/view/wallet_screens/mywallet_screen.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/custombutton.dart';

class CreatewalletScreen extends StatelessWidget {
  const CreatewalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.black38,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {},
            child: FaIcon(
              Icons.format_align_left_sharp,
              color: AppConstants.Primary,
              size: 26.sp,
            ),
          ),
          title: Text(
            "Wallet",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppConstants.Secondary,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Column(
                  children: [
                    SizedBox(height: 30.h),
                    Text(
                      "Secure Your\nDigital Assets Effortlessly",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppConstants.Secondary,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Connect your existing wallet or create a new one to start buying, selling, and managing your NFTs securely",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppConstants.Secondary,
                        fontSize: 12.sp,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      height: 150.h,
                      width: 200.w,
                      child: Image(image: AssetImage(AppConstants.Wallet)),
                    ),
                    SizedBox(height: 50.h),
                    Custombutton(
                      text: "Connect Wallet",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WalletScreen(),
                          ),
                        );
                      },
                      height: 55.h,
                      width: double.infinity,
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.Secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            side: BorderSide(
                              color: AppConstants.Primary,
                              width: 0.9.w,
                            ),
                          ),
                        ),
                        child: Text(
                          "Create a Wallet",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
