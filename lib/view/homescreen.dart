import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/widgets/app_background.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  print("object");
                },
                icon: Transform.scale(
                  scaleY: -1,
                  child: FaIcon(
                    FontAwesomeIcons.alignLeft,
                    color: AppConstants.Primary,
                    size: 50.sp,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Home Screen",
                  style: TextStyle(
                    color: AppConstants.Secondary,
                    fontSize: 50.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
