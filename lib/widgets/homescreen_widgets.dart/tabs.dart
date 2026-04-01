import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';

class CustomTabs extends StatefulWidget {
  const CustomTabs({super.key});

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> {
  int selectedIndex = 1;

  final List<String> tabList = ["Recent", "Top NFTs", "My NFTs", "Gaming"];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabList.length, (index) {
          bool isActive = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Column(
                children: [
                  Text(
                    tabList[index],
                    style: TextStyle(
                      color: isActive ? Colors.orange : Colors.grey,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 15.sp,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isActive)
                    Container(
                      height: 3,
                      width: 35.w,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

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
}
