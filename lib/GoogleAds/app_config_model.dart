class AppConfigModelRes {
  final int? status;
  final String? message;
  final AppConfigModel? data;

  AppConfigModelRes({
    this.status,
    this.message,
    this.data,
  });

  factory AppConfigModelRes.fromJson(Map<String, dynamic> json) =>
      AppConfigModelRes(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : AppConfigModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class AppConfigModel {
  final String androidMinVersion;
  final String androidLatestVersion;
  final String playStoreUrl;

  AppConfigModel({
    required this.androidMinVersion,
    required this.androidLatestVersion,
    required this.playStoreUrl,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) => AppConfigModel(
        androidMinVersion: json["android_min_version"],
        androidLatestVersion: json["android_latest_version"],
        playStoreUrl: json["play_store_url"],
      );

  Map<String, dynamic> toJson() => {
        "android_min_version": androidMinVersion,
        "android_latest_version": androidLatestVersion,
        "play_store_url": playStoreUrl,
      };
}
