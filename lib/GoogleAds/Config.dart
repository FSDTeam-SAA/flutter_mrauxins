import 'package:two_one_two_messenger/GoogleAds/config_model.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';

class Config {
  // ConfigController configController = Get.find<ConfigController>();

  // admobopenAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admobAppopen;
  // }

  // admobinterstitialAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admobInterstital;
  // }

  // admobinterstitialRewardAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admobInterstitalReward;
  // }

  // admobnativeAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admobNative;
  // }

  admobbannerAdUnitId() async {
    // ConfigModel? config =
    //     await configController.getConfigFromSharedPreferences();
    return adConfigCubit.state.configModel?.admobBanner;
  }

  // admobrewardAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admobReward;
  // }

  // adManageropenAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admobAppopen;
  // }

  // adManagerinterstitialAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admanagerInterstital;
  // }

  // adManagerinterstitialRewardAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admanagerInterstitalReward;
  // }

  // adManagernativeAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admanagerNative;
  // }

  adManagerbannerAdUnitId() async {
    // ConfigModel? config =
    //     await configController.getConfigFromSharedPreferences();
    return adConfigCubit.state.configModel?.admanagerBanner;
  }

  // adManagerrewardAdUnitId() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.admanagerReward;
  // }

  adsShow() async {
   
        await adConfigCubit.getConfigFromSharedPreferences();

    return adConfigCubit.state.configModel?.adsShow??"on";
  }

  // intersClick() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.interstitialCount;
  // }

  // intersBackClick() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.interstitialBackcount;
  // }

  // activityShow() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.activityShow;
  // }

  // adBlocker() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.adBlocker;
  // }

  // appOpen() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.appopen;
  // }

  // extraActivity() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.extraActivity;
  // }

  // intersExtraClick() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.interstitialExtraAdcount;
  // }

  // intersStartScreenAd() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.interstitialStartScreenAd;
  // }

  // whichAppOpen() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.adAppopen;
  // }

  // whichInters() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.adAppopen;
  // }

  // whichIntersReward() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.adAppopen;
  // }

  // whichNative() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.adAppopen;
  // }

  // whichBanner() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.adAppopen;
  // }

  // whichReward() async {
  //   ConfigModel? config =
  //       await configController.getConfigFromSharedPreferences();
  //   return config?.adAppopen;
  // }
}
