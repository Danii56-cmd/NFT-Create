import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NFTCard extends StatelessWidget {
  const NFTCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 241.h,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xff2a2a2a),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE + HEART
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    height: 120,
                    width: 150.w,
                    "https://i.imgur.com/BoN9kdC.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// HEART BADGE
              Positioned(
                top: 8,
                right: 4,
                child: Container(
                  height: 13.h,
                  width: 33.w,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 8),
                      SizedBox(width: 4),
                      Text(
                        "100",
                        style: TextStyle(color: Colors.white, fontSize: 6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          /// TITLE + RATING + INFO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stylish Monkey",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),

              Row(
                children: const [
                  Icon(Icons.star, color: Colors.orange, size: 8),
                  Icon(Icons.star, color: Colors.orange, size: 8),
                  Icon(Icons.star_border, color: Colors.orange, size: 8),
                  SizedBox(width: 5),
                  Icon(Icons.info_outline, color: Colors.grey, size: 12),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// OWNER + PRICE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// OWNER
              Row(
                children: [
                  Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: NetworkImage("https://i.pravatar.cc/150?img=3"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "Jhon Wick",
                    style: TextStyle(color: Colors.grey, fontSize: 8.sp),
                  ),
                ],
              ),

              /// PRICE
              Text(
                "549\$",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// BUTTONS
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Your action here
                  },
                  child: Container(
                    height: 24.h,

                    width: 110.w,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Buy Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
