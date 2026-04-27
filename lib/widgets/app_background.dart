import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.sh,
      width: 1.sh,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppConstants.BgImage),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
