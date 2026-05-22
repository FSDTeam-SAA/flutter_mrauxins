// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:two_one_two_messenger/GoogleAds/Config.dart';
// import 'package:two_one_two_messenger/extension/bloc.dart';
// import 'package:two_one_two_messenger/main.dart';
// import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

// class RewardAdManager {
//   RewardedAd? rewardedAd;
//   // AdsConfigController adsConfigController =
//   //     Get.put(AdsConfigController(), permanent: true);

//   loadAd({VoidCallback? callback}) async {
//     showd();
//     if (await adsCubit.getRewardValue() == "admob") {
//       RewardedAd.load(
//           adUnitId: await Config().admobrewardAdUnitId(),
//           request: const AdRequest(),
//           rewardedAdLoadCallback: RewardedAdLoadCallback(
//             onAdFailedToLoad: (error) {
//               Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
//                   .pop();
//               log('RewardAd failed to load: $error');
//               if (callback != null) {
//                 callback();
//               }
//             },
//             onAdLoaded: (ad) {
//               rewardedAd = ad;
//               Navigator.of(navigatorKey.currentContext!).pop();
//               rewardedAd?.show(
//                 onUserEarnedReward: (ad, reward) {
//                   log(reward.amount.toString());
//                 },
//               );
//               ad.fullScreenContentCallback = FullScreenContentCallback(
//                 onAdDismissedFullScreenContent: (ad) {
//                   ad.dispose();
//                   if (callback != null) {
//                     callback();
//                   }
//                 },
//                 onAdFailedToShowFullScreenContent: (ad, error) {
//                   ad.dispose();
//                   if (callback != null) {
//                     callback();
//                   }
//                 },
//               );
//             },
//           ));
//     } else {
//       RewardedAd.loadWithAdManagerAdRequest(
//           adManagerRequest: const AdManagerAdRequest(),
//           adUnitId: await Config().adManagerrewardAdUnitId(),
//           rewardedAdLoadCallback: RewardedAdLoadCallback(
//             onAdFailedToLoad: (error) {
//               Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
//                   .pop();
//               log('RewardAd failed to load: $error');
//               if (callback != null) {
//                 callback();
//               }
//             },
//             onAdLoaded: (ad) {
//               rewardedAd = ad;
//               Navigator.of(navigatorKey.currentContext!).pop();
//               rewardedAd?.show(
//                 onUserEarnedReward: (ad, reward) {
//                   log(reward.amount.toString());
//                 },
//               );
//               ad.fullScreenContentCallback = FullScreenContentCallback(
//                 onAdDismissedFullScreenContent: (ad) {
//                   ad.dispose();
//                   if (callback != null) {
//                     callback();
//                   }
//                 },
//                 onAdFailedToShowFullScreenContent: (ad, error) {
//                   ad.dispose();
//                   if (callback != null) {
//                     callback();
//                   }
//                 },
//               );
//             },
//           ));
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
