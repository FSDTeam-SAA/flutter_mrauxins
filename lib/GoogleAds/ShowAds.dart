

// class ShowAppOpenAds {
//   int click = 0;

//   showAppOpenAds({VoidCallback? callback}) async {
//     if (await Config().adsShow() == "on") {
//       final appOpenAdManager = AppOpenAdManager();
//       appOpenAdManager.loadAd();
//       return initAppOpen(callback: callback);
//     } else {
//       if (callback != null) {
//         Future.delayed(const Duration(seconds: 3))
//             .then((value) => {callback()});
//       }
//     }
//   }

//   void initAppOpen({VoidCallback? callback}) {
//     final appOpenAdManager = AppOpenAdManager();
//     appOpenAdManager.loadAd();

//     Timer(const Duration(seconds: 2), () {
//       if (appOpenAdManager.isAdAvailable) {
//         appOpenAdManager.showAdIfAvailable(onAdDismissed: callback);
//       } else {
//         if (callback != null) {
//           callback();
//         }
//       }
//     });

//     final appLifecycleReactor =
//         AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
//     appLifecycleReactor.listenToAppStateChanges();
//   }
// }

// class ShowInterstitialAds {
//   InterstitialAdManager adManager = InterstitialAdManager();

//   showClickInterstitialAds({VoidCallback? callback}) async {
//     await SpHelper().initialize();

//     int currentClick = await SpHelper.getclick();

//     int interval = int.parse(await Config().intersClick());
//     if (interval != 0 &&
//         currentClick % interval == 0 &&
//         await Config().adsShow() == "on") {
//       if (await Config().adsShow() == "on") {
//         adManager.loadAd(callback: callback);
//         await SpHelper.resetClick();
//       }
//     } else {
//       if (callback != null) {
//         callback();
//       }
//     }
//     await SpHelper.incrementClick();
//   }

//   showBackClickInterstitialAds({VoidCallback? callback}) async {
//     await SpHelper().initialize();

//     int currentClick = await SpHelper.getBackclick();

//     int interval = await Config().intersBackClick();

//     if (interval != 0 &&
//         currentClick % interval == 0 &&
//         await Config().adsShow()) {
//       if (await Config().adsShow()) {
//         adManager.loadAd(callback: callback);
//         await SpHelper.resetBackClick();
//       }
//     } else {
//       if (callback != null) {
//         callback();
//       }
//     }
//     await SpHelper.incrementBackClick();
//   }

//   showInterstitialAds({VoidCallback? callback}) async {
//     var adson = await Config().adsShow() == "on";
//     if (adson) {
//       adManager.loadAd(callback: callback);
//     } else {
//       if (callback != null) {
//         callback();
//       }
//     }
//   }
// }

// class ShowInterstitialRewardAd {
//   InterstitialRewardAdManager interstitialRewardAdManager =
//       InterstitialRewardAdManager();

//   showInterstitialRewardAds({VoidCallback? callback}) async {
//     var adson = await Config().adsShow() == "on";
//     if (adson) {
//       interstitialRewardAdManager.loadAd(callback: callback);
//     } else {
//       if (callback != null) {
//         callback();
//       }
//     }
//   }

//   showClickInterstitialRewardAds({VoidCallback? callback}) async {
//     await SpHelper().initialize();

//     int currentClick = await SpHelper.getclick();

//     int interval = int.parse(await Config().intersClick());
//     if (interval != 0 &&
//         currentClick % interval == 0 &&
//         await Config().adsShow() == "on") {
//       if (await Config().adsShow() == "on") {
//         interstitialRewardAdManager.loadAd(callback: callback);

//         await SpHelper.resetClick();
//       }
//     } else {
//       if (callback != null) {
//         callback();
//       }
//     }
//     await SpHelper.incrementClick();
//   }
// }

// class ShowRewardAd {
//   RewardAdManager rewardAdManager = RewardAdManager();

//   showClickRewardAds({VoidCallback? callback}) async {
//     await SpHelper().initialize();

//     int currentClick = await SpHelper.getclick();

//     int interval = int.parse(await Config().intersClick());
//     if (interval != 0 &&
//         currentClick % interval == 0 &&
//         await Config().adsShow() == "on") {
//       if (await Config().adsShow() == "on") {
//         rewardAdManager.loadAd(callback: callback);
//         await SpHelper.resetClick();
//       }
//     } else {
//       if (callback != null) {
//         callback();
//       }
//     }
//     await SpHelper.incrementClick();
//   }

//   showRewardAds({VoidCallback? callback}) async {
//     var adson = await Config().adsShow() == "on";
//     if (adson) {
//       rewardAdManager.loadAd(callback: callback);
//     } else {
//       if (callback != null) {
//         callback();
//       }
//     }
//   }
// }
