import 'package:flutter/material.dart';
import 'package:nft_create/widgets/app_background.dart';

class CreateScreens extends StatefulWidget {
  const CreateScreens({super.key});

  @override
  State<CreateScreens> createState() => _CreateScreensState();
}

class _CreateScreensState extends State<CreateScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(child: Column(children: [Text('Create Screen')])),
    );
  }
}
