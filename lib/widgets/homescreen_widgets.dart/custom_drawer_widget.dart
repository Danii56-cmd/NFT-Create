import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// PROFILE SECTION
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage("assets/avatar.png"),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        "CODEXDEV",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "650ae27d...",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.copy, color: Colors.grey, size: 18),
                ],
              ),

              const SizedBox(height: 50),

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
                            color: isActive ? Colors.white : Colors.grey,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (isActive)
                          Container(
                            height: 3,
                            width: 35,
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
            ],
          ),
        ),
      ),
    );
  }
}
