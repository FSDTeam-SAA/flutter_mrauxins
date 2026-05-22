import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../main.dart';

class Loader {
  static Future<void> show() async {
    EasyLoading.show(
      dismissOnTap: false,
      // maskType: EasyLoadingMaskType.black,
      // indicator: CustomLoadingWidget(
      //   size: 45.h,
      // )
    );
    // navigatorKey.currentState?.context.loaderOverlay.show();
  }

  static Future<void> hide() async {
    EasyLoading.dismiss();
    // navigatorKey.currentState?.context.loaderOverlay.hide();
  }
}

class CommonLoader {
  CommonLoader();
  static showLoader() async {
    EasyLoading.show(
      dismissOnTap: false,
      // maskType: EasyLoadingMaskType.black,
      // indicator: CustomLoadingWidget(
      //   size: 45.h,
      // )
    );
  }

  static hideLoader() {
    EasyLoading.dismiss();
  }
}
