import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_one_two_messenger/GoogleAds/config_model.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/services/api_client.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class AdsConfigState extends Equatable {
  final ConfigModel? configModel;
  final bool isLoading;
  final String? errorMessage;

  const AdsConfigState({
    this.configModel,
    this.isLoading = false,
    this.errorMessage,
  });

  AdsConfigState copyWith({
    ConfigModel? configModel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdsConfigState(
      configModel: configModel ?? this.configModel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [configModel, isLoading, errorMessage];
}

class AdsConfigCubit extends Cubit<AdsConfigState> {
  late SharedPreferences sharedPreferences;
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  AdsConfigCubit(this.apiClient, this.dbHelper)
      : super(const AdsConfigState()) {
    init();
  }

  Future<void> init() async {
    // sharedPreferences = await SharedPreferences.getInstance();
    getAdsConfigData();
  }

  Future<void> getAdsConfigData() async {
    try {
      // Utils.showLoader();

      ConfigModelRes response = await apiClient.getAdsConfig();
      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(configModel: response.data, isLoading: false));
      }
    } catch (e, st) {
      debugPrint("Error in geting ads config--$e, $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<String?> _getValue(String key, List<String> list) async {
    int count = sharedPreferences.getInt(key) ?? 0;
    String? value;
    if (list.isNotEmpty) {
      value = list[count % list.length];
      count++;
      await sharedPreferences.setInt(key, count);
    }
    return value;
  }

  Future<void> getConfigFromSharedPreferences() async {
    emit(state.copyWith(isLoading: true));
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? configJson = prefs.getString("configKey");
      if (configJson != null) {
        final configModel = configModelFromJson(configJson);
        emit(state.copyWith(configModel: configModel, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<String?> getBannerValue() async {
    // if (state.configModel == null) {
    //   await getConfigFromSharedPreferences();
    // }
    return "admob";

    //  _getValue("value5", state.configModel?.adBanner ?? []);
  }
}

// class AdsConfigController extends GetxController {
//   ConfigModel? configModel;
//   late SharedPreferences sharedPreferences;

//   @override
//   void onInit() {
//     super.onInit();
//     init();
//   }

//   Future<void> init() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//   }

//   Future<String?> _getValue(String key, List<String> list) async {
//     await init();
//     int count = sharedPreferences.getInt(key) ?? 0;
//     String? value;
//     if (list.isNotEmpty) {
//       value = list[count % list.length];
//       count++;
//       sharedPreferences.setInt(key, count);
//       update();
//     }
//     return value;
//   }

//   // Future<String?> getAppOpenValue() async {
//   //   configModel = await configController.getConfigFromSharedPreferences();
//   //   return _getValue("value1", configModel!.adAppopen);
//   // }

//   // Future<String?> getInterValue() async {
//   //   configModel = await configController.getConfigFromSharedPreferences();
//   //   return _getValue("value2", configModel!.adInter);
//   // }

//   // Future<String?> getInterRewardValue() async {
//   //   configModel = await configController.getConfigFromSharedPreferences();
//   //   return _getValue("value3", configModel!.adInterReward);
//   // }

//   // Future<String?> getNativeValue() async {
//   //   configModel = await configController.getConfigFromSharedPreferences();
//   //   return _getValue("value4", configModel!.adNative);
//   // }

//   Future<String?> getBannerValue() async {
//     // configModel = await adConfigCubit.getConfigFromSharedPreferences();
//     return _getValue("value5", adConfigCubit.state.configModel!.adBanner);
//   }

//   // Future<String?> getRewardValue() async {
//   //   configModel = await configController.getConfigFromSharedPreferences();
//   //   return _getValue("value6", configModel!.adReward);
//   // }
// }
