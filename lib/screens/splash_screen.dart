import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/send_otp_cubit.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
// adConfigCubit.fetchConfig();
    // Navigate to the main screen after 3 seconds
    Timer(Duration(seconds: 3), () async {
      await context.read<SendOtpCubit>().getLoginDataAndNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              ImgAssets.splashBg, // Path to your image
              fit: BoxFit.cover,
            ),
          ),
          // Logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImgAssets.logo, // Path to your logo
                  width: 140.w,
                  height: 140.h, // Adjust size as needed
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
