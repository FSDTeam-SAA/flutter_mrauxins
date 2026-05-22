// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:two_one_two_messenger/GoogleAds/Config.dart';
// import 'package:two_one_two_messenger/main.dart';
// import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

// class InterstitialAdManager {
//   InterstitialAd? interstitialAd;
//   AdManagerInterstitialAd? _interstitialAd;
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
//       log("messages");
//       if (callback != null) {
//         callback();
//       }
//     } else {
//       showd();
//       if (await adsConfigController.getInterValue() == "admob") {
//         InterstitialAd.load(
//             adUnitId: await Config().admobinterstitialAdUnitId(),
//             request: const AdRequest(),
//             adLoadCallback: InterstitialAdLoadCallback(
//               onAdLoaded: (ad) {
//                 adTimer.cancel(); // Cancel timer since ad loaded
//                 log('$ad loaded.');
//                 Navigator.of(navigatorKey.currentContext!).pop();
//                 isLoaded = true;
//                 interstitialAd = ad;
//                 interstitialAd!.show();
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
//         AdManagerInterstitialAd.load(
//             adUnitId: await Config().adManagerinterstitialAdUnitId(),
//             request: const AdManagerAdRequest(),
//             adLoadCallback: AdManagerInterstitialAdLoadCallback(
//               onAdLoaded: (ad) {
//                 adTimer.cancel(); // Cancel timer since ad loaded
//                 log('$ad loaded.');
//                 Navigator.of(navigatorKey.currentContext!).pop();
//                 isLoaded = true;
//                 _interstitialAd = ad;
//                 _interstitialAd!.show();
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
//       barrierColor: Colors.black.withOpacity(0.8),
//     );
//   }
// }
