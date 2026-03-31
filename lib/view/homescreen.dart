import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/widgets/app_background.dart';
import 'package:nft_create/widgets/homescreen_widgets.dart/nft_card_widget.dart';
import 'package:nft_create/widgets/homescreen_widgets.dart/tabs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: const Color(0xff1e1e1e),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),

                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, color: Colors.orange, size: 28),
                    const Text(
                      "Explore NFT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Stack(
                      children: const [
                        Icon(
                          Icons.notifications_none,
                          color: Colors.orange,
                          size: 28,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                /// SEARCH BAR
                Center(
                  child: Container(
                    height: 44,
                    width: 310.w,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.orange, width: 1.5.w),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.orange),
                        SizedBox(width: 10),
                        Text("Search", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// TABS (FIXED)
                CustomTabs(),

                const SizedBox(height: 20),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 170 / 280,
                  ),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return const NFTCard();
                  },
                ),

                const SizedBox(height: 25),

                Container(
                  height: 243.h,
                  width: 360.w,
                  decoration: BoxDecoration(
                    color: const Color(0xff2a2a2a),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // White Container (Everything inside it as per screenshot)
                      Container(
                        height: 210.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Balance",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [],
                                ),
                                Text(
                                  "\$18500",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Icon(
                                  Icons.visibility_outlined,
                                  color: Colors.black,
                                  size: 10,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Chart Image + Button in Row (Side by Side)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Chart Image (Takes most space)
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    height: 126.h, // Fixed height for chart
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/images/balancechart.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // Top Up Balance Button - Moved to bottom right
                                Align(
                                  alignment: Alignment
                                      .bottomRight, // ← This pushes button to bottom right
                                  child: InkWell(
                                    onTap: () {
                                      // Your action here
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          Text(
                                            "Top Up Balance",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.orange),
          ),
          child: Padding(
            padding: EdgeInsets.all(7.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomIcon(Icons.home, "Home"),
                BottomIcon(Icons.add, "Create"),
                BottomIcon(Icons.bar_chart, "Market"),
                BottomIcon(Icons.wallet, "Wallet"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// BOTTOM ICON
class BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const BottomIcon(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
