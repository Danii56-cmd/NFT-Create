import 'package:flutter/material.dart';
import 'package:nft_create/widgets/app_background.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(child: Column(children: [Text('Market screen')])),
    );
  }
}
