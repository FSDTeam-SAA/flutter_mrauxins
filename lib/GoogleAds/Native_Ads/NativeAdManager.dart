// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:two_one_two_messenger/GoogleAds/Config.dart';

// class NativeAdManager extends StatefulWidget {
//   const NativeAdManager({super.key});

//   @override
//   State<NativeAdManager> createState() => _NativeAdManagerState();
// }

// class _NativeAdManagerState extends State<NativeAdManager> {
//   NativeAd? _nativeAd;
//   NativeAd? nativeAdx;
//   bool nativeAdIsLoaded = false;
//   bool showNative = false;
//   bool isadmob = false;
//   AdsConfigController adsConfigController = Get.find<AdsConfigController>();

//   @override
//   initState() {
//     super.initState();
//     showBannerCheck();
//   }

//   showBannerCheck() async {
//     showNative = await Config().adsShow() == "on";

//     if (showNative) {
//       isadmob = await adsConfigController.getNativeValue() == "admob";
//       await loadAd();
//       setState(() {});
//     }
//   }

//   Future<void> loadAd() async {
//     if (isadmob) {
//       _nativeAd = NativeAd(
//         adUnitId: await Config().admobnativeAdUnitId(),
//         request: const AdRequest(),
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             log('$ad loaded.');
//             nativeAdIsLoaded = true;
//             setState(() {});
//           },
//           onAdFailedToLoad: (ad, err) {
//             log('Native failed to loads: $err');
//             ad.dispose();
//           },
//         ),
//         nativeTemplateStyle: NativeTemplateStyle(
//           templateType: TemplateType.small,
//           mainBackgroundColor: Colors.white,
//           cornerRadius: 10,
//           callToActionTextStyle:
//               NativeTemplateTextStyle(size: 16.0, backgroundColor: Colors.blue),
//           primaryTextStyle: NativeTemplateTextStyle(
//             textColor: Colors.black,
//           ),
//         ),
//       )..load();
//     } else {
//       nativeAdx = NativeAd(
//         adUnitId: await Config().adManagernativeAdUnitId(),
//         request: const AdManagerAdRequest(),
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             log('$ad loaded.');
//             nativeAdIsLoaded = true;
//             setState(() {});
//           },
//           onAdFailedToLoad: (ad, err) {
//             log('Native failed to loads: $err');
//             ad.dispose();
//           },
//         ),
//         nativeTemplateStyle: NativeTemplateStyle(
//           templateType: TemplateType.small,
//           mainBackgroundColor: Colors.white,
//           cornerRadius: 10,
//           callToActionTextStyle:
//               NativeTemplateTextStyle(size: 16.0, backgroundColor: Colors.blue),
//           primaryTextStyle: NativeTemplateTextStyle(
//             textColor: Colors.black,
//           ),
//         ),
//       )..load();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return showNative && nativeAdIsLoaded
//         ? isadmob
//             ? ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   minWidth: 300,
//                   minHeight: 300,
//                   maxHeight: 400,
//                   maxWidth: 400,
//                 ),
//                 child: AdWidget(ad: _nativeAd!),
//               )
//             : ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   minWidth: 300,
//                   minHeight: 300,
//                   maxHeight: 400,
//                   maxWidth: 400,
//                 ),
//                 child: AdWidget(ad: nativeAdx!),
//               )
//         : const SizedBox();
//   }
// }
