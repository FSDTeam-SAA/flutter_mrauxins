import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:two_one_two_messenger/cubit/version_check_state.dart';
import 'package:two_one_two_messenger/services/api_client.dart';

class VersionCheckCubit extends Cubit<VersionCheckState> {
  final ApiClient apiClient;

  VersionCheckCubit(this.apiClient) : super(const VersionCheckState());

  /// Returns true when the running app is below the server's minimum
  /// supported Android version and must be blocked behind the update screen.
  /// Fails open (returns false) on any network/parse error so a backend
  /// hiccup never locks users out of the app.
  Future<bool> checkVersion() async {
    if (!Platform.isAndroid) return false;

    emit(state.copyWith(isLoading: true));
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = Version.parse(packageInfo.version);

      final response = await apiClient.checkAppVersion();
      final config = response.data;
      if (config == null) {
        emit(state.copyWith(isLoading: false));
        return false;
      }

      final minVersion = Version.parse(config.androidMinVersion);
      final updateRequired = localVersion < minVersion;

      emit(state.copyWith(
        isLoading: false,
        updateRequired: updateRequired,
        playStoreUrl: config.playStoreUrl,
      ));
      return updateRequired;
    } catch (e) {
      emit(state.copyWith(isLoading: false, updateRequired: false));
      return false;
    }
  }
}
