// // To parse this JSON data, do
// //
// //     final configModel = configModelFromJson(jsonString);

// import 'dart:convert';

// ConfigModel configModelFromJson(String str) =>
//     ConfigModel.fromJson(json.decode(str));

// String configModelToJson(ConfigModel data) => json.encode(data.toJson());

// class ConfigModel {
//   // String admobAppopen;
//   // String admobInterstital;
//   // String admobInterstitalReward;
//   // String admobReward;
//   String admobBanner;
//   // String admobNative;
//   // String admanagerAppopen;
//   // String admanagerInterstital;
//   // String admanagerInterstitalReward;
//   // String admanagerReward;
//   String admanagerBanner;
//   // String admanagerNative;
//   String adsShow;
//   // String activityShow;
//   // String adBlocker;
//   // String appopen;
//   // int extraActivity;
//   // String interstitialExtraAdcount;
//   // String interstitialCount;
//   // String interstitialBackcount;
//   // String interstitialStartScreenAd;
//   // String appopenType;
//   // List<String> adAppopen;
//   // List<String> adInter;
//   // List<String> adInterReward;
//   // List<String> adNative;
//   List<String> adBanner;
//   // List<String> adReward;

//   ConfigModel({
//     // required this.admobAppopen,
//     // required this.admobInterstital,
//     // required this.admobInterstitalReward,
//     // required this.admobReward,
//     required this.admobBanner,
//     // required this.admobNative,
//     // required this.admanagerAppopen,
//     // required this.admanagerInterstital,
//     // required this.admanagerInterstitalReward,
//     // required this.admanagerReward,
//     required this.admanagerBanner,
//     // required this.admanagerNative,
//     required this.adsShow,
//     // required this.activityShow,
//     // required this.adBlocker,
//     // required this.appopen,
//     // required this.extraActivity,
//     // required this.interstitialExtraAdcount,
//     // required this.interstitialCount,
//     // required this.interstitialBackcount,
//     // required this.interstitialStartScreenAd,
//     // required this.appopenType,
//     // required this.adAppopen,
//     // required this.adInter,
//     // required this.adInterReward,
//     // required this.adNative,
//     required this.adBanner,
//     // required this.adReward,
//   });

//   factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
//         admobBanner: json["admob_banner"],
//         adsShow: json["ads_show"],
//         admanagerBanner: json["ads_manager"],
//         adBanner: List<String>.from(json["ad_banner"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "admob_banner": admobBanner,
//         "admanager_banner": admanagerBanner,
//         "ads_show": adsShow,
//         "ad_banner": List<dynamic>.from(adBanner.map((x) => x)),
//       };
// }

import 'dart:convert';

class ConfigModelRes {
  final int? status;
  final String? message;
  final ConfigModel? data;

  ConfigModelRes({
    this.status,
    this.message,
    this.data,
  });

  ConfigModelRes copyWith({
    int? status,
    String? message,
    ConfigModel? data,
  }) =>
      ConfigModelRes(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ConfigModelRes.fromJson(Map<String, dynamic> json) => ConfigModelRes(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? ConfigModel.fromJson(json = {
                "admob_appopen": "ca-app-pub-3940256099942544/9257395921",
                "admob_interstital": "ca-app-pub-3940256099942544/1033173712",
                "admob_interstital_reward":
                    "ca-app-pub-3940256099942544/5354046379",
                "admob_reward": "ca-app-pub-3940256099942544/5224354917",
                "admob_banner": "ca-app-pub-3940256099942544/6300978111",
                "admob_native": "ca-app-pub-3940256099942544/2247696110",
                "admanager_appopen": "/6499/example/app-open",
                "admanager_interstital": "/6499/example/interstitial",
                "admanager_interstital_reward":
                    "/21775744923/example/rewarded_interstitial",
                "admanager_reward": "/6499/example/rewarded",
                "admanager_banner": "/6499/example/banner",
                "admanager_native": "/6499/example/native",
                "ads_show": "on",
                "activity_show": "on",
                "ad_blocker": "off",
                "appopen": "on",
                "extra_activity": 4,
                "interstitial_extra_adcount": "2",
                "interstitial_count": "1",
                "interstitial_backcount": "1",
                "interstitial_start_screen_ad": "on",
                "appopen_type": "admob",
                "ad_appopen": [
                  "admob",
                ],
                "ad_inter": [
                  "admob",
                ],
                "ad_inter_reward": [
                  "admob",
                ],
                "ad_native": [
                  "admob",
                ],
                "ad_banner": [
                  "admob",
                ],
                "ad_reward": [
                  "admob",
                ]
              })
            : ConfigModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

ConfigModel configModelFromJson(String str) =>
    ConfigModel.fromJson(json.decode(str));

String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConfigModel {
  final String admobAppopen;
  final String admobInterstital;
  final String admobInterstitalReward;
  final String admobReward;
  final String admobBanner;
  final String admobNative;
  final String admanagerAppopen;
  final String admanagerInterstital;
  final String admanagerInterstitalReward;
  final String admanagerReward;
  final String admanagerBanner;
  final String admanagerNative;
  final String adsShow;
  final String activityShow;
  final String adBlocker;
  final String appopen;
  final int extraActivity;
  final String interstitialExtraAdcount;
  final String interstitialCount;
  final String interstitialBackcount;
  final String interstitialStartScreenAd;
  final String appopenType;
  final List<String> adAppopen;
  final List<String> adInter;
  final List<String> adInterReward;
  final List<String> adNative;
  final List<String> adBanner;
  final List<String> adReward;

  ConfigModel({
    required this.admobAppopen,
    required this.admobInterstital,
    required this.admobInterstitalReward,
    required this.admobReward,
    required this.admobBanner,
    required this.admobNative,
    required this.admanagerAppopen,
    required this.admanagerInterstital,
    required this.admanagerInterstitalReward,
    required this.admanagerReward,
    required this.admanagerBanner,
    required this.admanagerNative,
    required this.adsShow,
    required this.activityShow,
    required this.adBlocker,
    required this.appopen,
    required this.extraActivity,
    required this.interstitialExtraAdcount,
    required this.interstitialCount,
    required this.interstitialBackcount,
    required this.interstitialStartScreenAd,
    required this.appopenType,
    required this.adAppopen,
    required this.adInter,
    required this.adInterReward,
    required this.adNative,
    required this.adBanner,
    required this.adReward,
  });

  ConfigModel copyWith({
    String? admobAppopen,
    String? admobInterstital,
    String? admobInterstitalReward,
    String? admobReward,
    String? admobBanner,
    String? admobNative,
    String? admanagerAppopen,
    String? admanagerInterstital,
    String? admanagerInterstitalReward,
    String? admanagerReward,
    String? admanagerBanner,
    String? admanagerNative,
    String? adsShow,
    String? activityShow,
    String? adBlocker,
    String? appopen,
    int? extraActivity,
    String? interstitialExtraAdcount,
    String? interstitialCount,
    String? interstitialBackcount,
    String? interstitialStartScreenAd,
    String? appopenType,
    List<String>? adAppopen,
    List<String>? adInter,
    List<String>? adInterReward,
    List<String>? adNative,
    List<String>? adBanner,
    List<String>? adReward,
  }) =>
      ConfigModel(
        admobAppopen: admobAppopen ?? this.admobAppopen,
        admobInterstital: admobInterstital ?? this.admobInterstital,
        admobInterstitalReward:
            admobInterstitalReward ?? this.admobInterstitalReward,
        admobReward: admobReward ?? this.admobReward,
        admobBanner: admobBanner ?? this.admobBanner,
        admobNative: admobNative ?? this.admobNative,
        admanagerAppopen: admanagerAppopen ?? this.admanagerAppopen,
        admanagerInterstital: admanagerInterstital ?? this.admanagerInterstital,
        admanagerInterstitalReward:
            admanagerInterstitalReward ?? this.admanagerInterstitalReward,
        admanagerReward: admanagerReward ?? this.admanagerReward,
        admanagerBanner: admanagerBanner ?? this.admanagerBanner,
        admanagerNative: admanagerNative ?? this.admanagerNative,
        adsShow: adsShow ?? this.adsShow,
        activityShow: activityShow ?? this.activityShow,
        adBlocker: adBlocker ?? this.adBlocker,
        appopen: appopen ?? this.appopen,
        extraActivity: extraActivity ?? this.extraActivity,
        interstitialExtraAdcount:
            interstitialExtraAdcount ?? this.interstitialExtraAdcount,
        interstitialCount: interstitialCount ?? this.interstitialCount,
        interstitialBackcount:
            interstitialBackcount ?? this.interstitialBackcount,
        interstitialStartScreenAd:
            interstitialStartScreenAd ?? this.interstitialStartScreenAd,
        appopenType: appopenType ?? this.appopenType,
        adAppopen: adAppopen ?? this.adAppopen,
        adInter: adInter ?? this.adInter,
        adInterReward: adInterReward ?? this.adInterReward,
        adNative: adNative ?? this.adNative,
        adBanner: adBanner ?? this.adBanner,
        adReward: adReward ?? this.adReward,
      );

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      admobAppopen: json["admob_appopen"],
      admobInterstital: json["admob_interstital"],
      admobInterstitalReward: json["admob_interstital_reward"],
      admobReward: json["admob_reward"],
      admobBanner: json["admob_banner"],
      admobNative: json["admob_native"],
      admanagerAppopen: json["admanager_appopen"],
      admanagerInterstital: json["admanager_interstital"],
      admanagerInterstitalReward: json["admanager_interstital_reward"],
      admanagerReward: json["admanager_reward"],
      admanagerBanner: json["admanager_banner"],
      admanagerNative: json["admanager_native"],
      adsShow: json["ads_show"],
      activityShow: json["activity_show"],
      adBlocker: json["ad_blocker"],
      appopen: json["appopen"],
      extraActivity: json["extra_activity"],
      interstitialExtraAdcount: json["interstitial_extra_adcount"],
      interstitialCount: json["interstitial_count"],
      interstitialBackcount: json["interstitial_backcount"],
      interstitialStartScreenAd: json["interstitial_start_screen_ad"],
      appopenType: json["appopen_type"],
      adAppopen: List<String>.from(json["ad_appopen"].map((x) => x)),
      adInter: List<String>.from(json["ad_inter"].map((x) => x)),
      adInterReward: List<String>.from(json["ad_inter_reward"].map((x) => x)),
      adNative: List<String>.from(json["ad_native"].map((x) => x)),
      adBanner: List<String>.from(json["ad_banner"].map((x) => x)),
      adReward: List<String>.from(json["ad_reward"].map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "admob_appopen": admobAppopen,
        "admob_interstital": admobInterstital,
        "admob_interstital_reward": admobInterstitalReward,
        "admob_reward": admobReward,
        "admob_banner": admobBanner,
        "admob_native": admobNative,
        "admanager_appopen": admanagerAppopen,
        "admanager_interstital": admanagerInterstital,
        "admanager_interstital_reward": admanagerInterstitalReward,
        "admanager_reward": admanagerReward,
        "admanager_banner": admanagerBanner,
        "admanager_native": admanagerNative,
        "ads_show": adsShow,
        "activity_show": activityShow,
        "ad_blocker": adBlocker,
        "appopen": appopen,
        "extra_activity": extraActivity,
        "interstitial_extra_adcount": interstitialExtraAdcount,
        "interstitial_count": interstitialCount,
        "interstitial_backcount": interstitialBackcount,
        "interstitial_start_screen_ad": interstitialStartScreenAd,
        "appopen_type": appopenType,
        "ad_appopen": List<dynamic>.from(adAppopen.map((x) => x)),
        "ad_inter": List<dynamic>.from(adInter.map((x) => x)),
        "ad_inter_reward": List<dynamic>.from(adInterReward.map((x) => x)),
        "ad_native": List<dynamic>.from(adNative.map((x) => x)),
        "ad_banner": List<dynamic>.from(adBanner.map((x) => x)),
        "ad_reward": List<dynamic>.from(adReward.map((x) => x)),
      };
}
