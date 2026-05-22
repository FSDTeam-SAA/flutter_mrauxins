// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:two_one_two_messenger/GoogleAds/Config.dart';
// import 'package:two_one_two_messenger/main.dart';
// import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

// class InterstitialRewardAdManager {
//   RewardedInterstitialAd? rewardeInterstitialdAdmob;
//   RewardedInterstitialAd? rewardeInterstitialdAdManager;

//   bool isLoaded = false;
//   bool adLoading = false;
//   late Timer adTimer;
//   AdsConfigController adsConfigController =
//       Get.put(AdsConfigController(), permanent: true);

//   Future<void> loadAd({VoidCallback? callback}) async {
//     adLoading = true;

//     adTimer = Timer(const Duration(seconds: 15), () {
//       if (!isLoaded) {
//         adLoading = false;
//         if (callback != null) {
//           callback();
//         }
//       }
//     });

//     if (await Config().adsShow() == "off") {
//       if (callback != null) {
//         callback();
//       }
//     } else {
//       showd();

//       if (await adsConfigController.getInterRewardValue() == "admob") {
//         log("''");
//         RewardedInterstitialAd.load(
//             adUnitId: await Config().admobinterstitialRewardAdUnitId(),
//             request: const AdRequest(),
//             rewardedInterstitialAdLoadCallback:
//                 RewardedInterstitialAdLoadCallback(
//               onAdLoaded: (ad) {
//                 adTimer.cancel(); // Cancel timer since ad loaded
//                 log('$ad loaded.');
//                 Navigator.of(navigatorKey.currentContext!).pop();
//                 isLoaded = true;
//                 rewardeInterstitialdAdmob = ad;
//                 rewardeInterstitialdAdmob!.show(
//                   onUserEarnedReward: (ad, reward) {},
//                 );
//                 ad.fullScreenContentCallback = FullScreenContentCallback(
//                   onAdDismissedFullScreenContent: (ad) {
//                     ad.dispose();
//                     if (callback != null) {
//                       callback();
//                     }
//                   },
//                   onAdFailedToShowFullScreenContent: (ad, error) {
//                     ad.dispose();
//                     if (callback != null) {
//                       callback();
//                     }
//                   },
//                 );
//               },
//               onAdFailedToLoad: (LoadAdError error) {
//                 adTimer.cancel(); // Cancel timer since ad failed to load
//                 Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
//                     .pop();
//                 log('InterstitialAd failed to load: $error');
//                 adLoading = false;
//                 if (callback != null) {
//                   callback();
//                 }
//               },
//             ));
//       } else {
//         RewardedInterstitialAd.loadWithAdManagerAdRequest(
//             adUnitId: await Config().adManagerinterstitialRewardAdUnitId(),
//             adManagerRequest: const AdManagerAdRequest(),
//             rewardedInterstitialAdLoadCallback:
//                 RewardedInterstitialAdLoadCallback(
//               onAdLoaded: (ad) {
//                 adTimer.cancel(); // Cancel timer since ad loaded
//                 log('$ad loaded.');
//                 Navigator.of(navigatorKey.currentContext!).pop();
//                 isLoaded = true;
//                 rewardeInterstitialdAdManager = ad;
//                 rewardeInterstitialdAdManager!.show(
//                   onUserEarnedReward: (ad, reward) {},
//                 );
//                 ad.fullScreenContentCallback = FullScreenContentCallback(
//                   onAdDismissedFullScreenContent: (ad) {
//                     ad.dispose();
//                     if (callback != null) {
//                       callback();
//                     }
//                   },
//                   onAdFailedToShowFullScreenContent: (ad, error) {
//                     ad.dispose();
//                     if (callback != null) {
//                       callback();
//                     }
//                   },
//                 );
//               },
//               onAdFailedToLoad: (LoadAdError error) {
//                 adTimer.cancel(); // Cancel timer since ad failed to load
//                 Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
//                     .pop();
//                 log('InterstitialAd failed to load: $error');
//                 adLoading = false;
//                 if (callback != null) {
//                   callback();
//                 }
//               },
//             ));
//       }
//     }
//   }

//   showd() {
//     showDialog(
//       context: navigatorKey.currentContext!,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(40),
//             child: CustomLoadingWidget(),
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//       barrierColor: Colors.black.withValues(alpha:0.8),
//     );
//   }
// }
