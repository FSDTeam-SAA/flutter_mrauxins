import 'package:http/http.dart' as http;
import 'package:two_one_two_messenger/GoogleAds/config_model.dart';
import 'package:bloc/bloc.dart';
import 'package:two_one_two_messenger/GoogleAds/config_state.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/services/api_client.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

// class ConfigController extends GetxController {
//   var isCall = false;
//   ConfigModel? configModel;

//   @override
//   onInit() {
//     super.onInit();
//     fetchConfig();
//   }

//   fetchConfig() async {
//     // final response =
//     //     await http.get(Uri.parse(apiUrl), headers: {"Accept": "*/*"});

//     // try {
//     //   if (response.statusCode == 200) {
//     //     configModel = configModelFromJson(response.body.toString());
//     //     await saveConfigToSharedPreferences(configModel!);

//     //     // log((Config().configController).configModel!.carousel[1].url);

//     //     isCall = true;
//     //   } else {
//     //     isCall = false;
//     //   }
//     // } on Exception catch (e) {
//     //   log(e.toString());
//     // }
//     // update();
//   }

//   Future<void> saveConfigToSharedPreferences(ConfigModel configModel) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("configKey", configModelToJson(configModel));
//     update();
//   }

//   Future<ConfigModel?> getConfigFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? configJson = prefs.getString("configKey");
//     if (configJson != null) {
//       return configModelFromJson(configJson);
//     }
//     update();
//     return null;
//   }
// }

class ConfigCubit extends Cubit<ConfigState> {
  final ApiClient apiClient;
  // final DatabaseHelper dbHelper;
  ConfigCubit(
    this.apiClient,
    // this.dbHelper
  ) : super(const ConfigState());

  Future<void> fetchConfig() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulated API call (replace with actual API request)
      // final response = await http.get(Uri.parse(apiUrl), headers: {"Accept": "*/*"});

      // if (response.statusCode == 200) {
      //   final configModel = configModelFromJson(response.body);
      //   await saveConfigToSharedPreferences(configModel);
      //   emit(state.copyWith(configModel: configModel, isCall: true, isLoading: false));
      // } else {
      //   emit(state.copyWith(isCall: false, isLoading: false));
      // }

      ConfigModelRes response = await apiClient.getAdsConfig();
      if (response.status == Utils.APISUCCESS) {
        print("get Ads Config==>${response.toJson()}");
        emit(state.copyWith(
          configModel: response.data,
          isLoading: false,
          isCall: true,
        ));
      }

      await saveConfigToSharedPreferences(
          state.configModel ?? ConfigModel.fromJson(ConfigModelRes().toJson()));
      // Simulated success
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> saveConfigToSharedPreferences(ConfigModel configModel) async {
    await AppPreference.setString("configKey", configModelToJson(configModel));
  }

  Future<void> getConfigFromSharedPreferences() async {
    final String? configJson = AppPreference.getString("configKey");

    if (configJson != null) {
      final configModel = configModelFromJson(configJson);
      emit(state.copyWith(configModel: configModel, isCall: true));
    }
  }
}
