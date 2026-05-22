// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:two_one_two_messenger/GoogleAds/Config.dart';

// class AppOpenAdManager {
//   final Duration maxCacheDuration = const Duration(hours: 4);
//   DateTime? appOpenLoadTime;
//   // AdsConfigController adsConfigController =
//   //     Get.put(AdsConfigController(), permanent: true);

//   AppOpenAd? appOpenAd;
//   bool _isShowingAd = false;

//   loanAdmanager() async {
//     if (await Config().adsShow() == "on" && await Config().appOpen() == "on") {
//       AppOpenAd.loadWithAdManagerAdRequest(
//         adUnitId: await Config().adManageropenAdUnitId(),
//         adManagerAdRequest: const AdManagerAdRequest(),
//         adLoadCallback: AppOpenAdLoadCallback(
//           onAdLoaded: (ad) {
//             appOpenLoadTime = DateTime.now();
//             appOpenAd = ad;
//             debugPrint('AppOpenAd loaded');
//           },
//           onAdFailedToLoad: (error) {
//             debugPrint('AppOpenAd failed to load: $error');
//           },
//         ),
//       );
//     }
//   }

//   loadAdmob() async {
//     if (await Config().adsShow() == "on" && await Config().appOpen() == "on") {
//       AppOpenAd.load(
//         adUnitId: await Config().admobopenAdUnitId(),
//         request: const AdRequest(),
//         adLoadCallback: AppOpenAdLoadCallback(
//           onAdLoaded: (ad) {
//             appOpenLoadTime = DateTime.now();
//             appOpenAd = ad;
//             debugPrint('AppOpenAd loaded');
//           },
//           onAdFailedToLoad: (error) {
//             debugPrint('AppOpenAd failed to load: $error');
//           },
//         ),
//       );
//     }
//   }

//   loadAd() async {
//     if (await adsConfigController.getAppOpenValue() == "admob") {
//       loadAdmob();
//     } else {
//       loanAdmanager();
//     }
//   }

//   bool get isAdAvailable {
//     return appOpenAd != null;
//   }

//   void showAdIfAvailable({VoidCallback? onAdDismissed}) {
//     if (!isAdAvailable) {
//       log('Tried to show ad before available.');
//       loadAd();
//       return;
//     }
//     if (_isShowingAd) {
//       log('Tried to show ad while already showing an ad.');
//       return;
//     }
//     if (appOpenLoadTime == null ||
//         DateTime.now().subtract(maxCacheDuration).isAfter(appOpenLoadTime!)) {
//       log('Maximum cache duration exceeded. Loading another ad.');
//       appOpenAd!.dispose();
//       appOpenAd = null;
//       // loadAd();
//       return;
//     }
//     appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (ad) {
//         _isShowingAd = true;
//         log('$ad onAdShowedFullScreenContent');
//       },
//       onAdFailedToShowFullScreenContent: (ad, error) {
//         log('$ad onAdFailedToShowFullScreenContent: $error');
//         _isShowingAd = false;
//         ad.dispose();
//         appOpenAd = null;
//         if (onAdDismissed != null) {
//           onAdDismissed();
//         }
//       },
//       onAdDismissedFullScreenContent: (ad) {
//         log('$ad onAdDismissedFullScreenContent');
//         _isShowingAd = false;
//         ad.dispose();
//         appOpenAd = null;
//         // loadAd();
//         if (onAdDismissed != null) {
//           onAdDismissed();
//         }
//       },
//     );
//     appOpenAd!.show();
//   }
// }
