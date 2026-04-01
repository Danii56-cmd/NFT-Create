import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_create/constants/const.dart';
import 'package:nft_create/widgets/app_background.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Mock data list - in a real app, this might come from a provider or API
  List<int> notifications = List.generate(10, (index) => index);

  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.black38,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Notifications",
            style: TextStyle(color: AppConstants.Secondary),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppConstants.Secondary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Text(
                          "No notifications",
                          style: TextStyle(color: AppConstants.Secondary),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppConstants.Primary,
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(50.r),
                                child: Image.asset(
                                  AppConstants.User,
                                  height: 40.h,
                                  width: 40.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                "Notification ${notifications[index]}",
                                style: TextStyle(
                                  color: AppConstants.Secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "New NFT activity detected.",
                                style: TextStyle(color: AppConstants.Secondary),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: AppConstants.Secondary,
                                ),
                                onPressed: () => deleteNotification(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
