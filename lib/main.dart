import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:nft_create/providers/nft_creator_provider.dart';
import 'package:nft_create/view/onboarding_screens/onboarding_mainscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 780),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NFTCreatorProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NFT App',
            home: const OnboardingMain(),
          ),
        );
      },
    );
  }
}
