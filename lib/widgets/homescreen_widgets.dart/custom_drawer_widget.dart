import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int activeIndex = 0;

  final List<String> menuItems = [
    "SETTINGS",
    "MY NFT",
    "MARKET",
    "DESIGN",
    "WALLET",
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff2b2b2b),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// PROFILE SECTION
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(AppConstants.User),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "CODEXDEV",
                        style: TextStyle(
                          color: AppConstants.Secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "650ae27d...",
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.copy, color: Colors.grey, size: 18.sp),
                ],
              ),

              SizedBox(height: 50.h),

              ...List.generate(menuItems.length, (index) {
                bool isActive = activeIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 38),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          menuItems[index],
                          style: TextStyle(
                            color: isActive
                                ? AppConstants.Secondary
                                : Colors.grey,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16.sp,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        if (isActive)
                          Container(
                            height: 3.h,
                            width: 35.w,
                            decoration: BoxDecoration(
                              color: AppConstants.Primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
