import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:two_one_two_messenger/GoogleAds/ConfigController.dart';
import 'package:two_one_two_messenger/GoogleAds/adsConfigController.dart';
import 'package:two_one_two_messenger/firebase_options.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/screens/connection_lost_screen.dart';
import 'package:two_one_two_messenger/services/calllit_handler.dart';
import 'package:two_one_two_messenger/services/in_app_purchase_service.dart';
import 'package:two_one_two_messenger/services/language_change_provider.dart';
import 'package:two_one_two_messenger/services/local_contact_service.dart';
import 'package:two_one_two_messenger/services/network_connection/connectivity_cubit.dart';
import 'package:two_one_two_messenger/services/network_connection/connectivity_state.dart';
import 'package:two_one_two_messenger/services/notification_handler.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/annotated_region.dart';
import 'cubit/chat_cubit.dart';
import 'cubit/create_stories_cubit.dart';
import 'cubit/home_cubit.dart';
import 'cubit/new_group_cubit.dart';
import 'cubit/otp_verify_cubit.dart';
import 'cubit/profile_cubit.dart';
import 'cubit/search_cubit.dart';
import 'cubit/send_otp_cubit.dart';
import 'cubit/stories_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'cubit/user_data_cubit.dart';
import 'cubit/view_stories_cubit.dart';
import 'database/local_db.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/push_notifications.dart';
import 'utils/constants.dart';
import 'utils/navigation.dart';
import 'utils/theme.dart';
import 'widgets/loader.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationHandler.handleNotification(); // Do NOT await — permission dialog blocks main() before runApp() on iOS
  final apiClient = ApiClient();
  await AppPreference.initMySharedPreferences();

  FireBaseNotification().firebaseCloudMessagingLSetup(apiClient);

  FireBaseNotification().setUpLocalNotification();

  SocketService().connect();
  CallKitEventHandler.initialize();
  MobileAds.instance.initialize();
  final dbHelper = DatabaseHelper();

  Utils.initEasyLoading();
  CallKitEventHandler.getActiveCall();
  InAppPurchaseService().initialize(); // Do NOT await — queryProductDetails contacts App Store and can hang on iOS
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider(
            create: (context) => UserDataCubit(dbHelper)..loadUserData(),
          ),
          BlocProvider(
            create: (context) => SendOtpCubit(apiClient, dbHelper),
          ),
          BlocProvider(
            create: (context) => PhoneInputCubit(),
          ),
          BlocProvider(
            create: (context) => OtpVerifyCubit(apiClient, dbHelper),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(apiClient, dbHelper),
          ),
          // BlocProvider(
          //   create: (context) => ProfilePickCubit(),
          // ),
          BlocProvider(
            create: (context) => SearchCubit(apiClient, dbHelper),
          ),
          BlocProvider(
            create: (context) => HomeCubit(apiClient, dbHelper,
                ContactService(apiClient: apiClient, dbHelper: dbHelper)),
          ),
          BlocProvider(
            create: (context) => ChatCubit(apiClient, dbHelper),
          ),
          // BlocProvider(
          //   create: (context) => SendMessageCubit(apiClient, dbHelper),
          // ),
          BlocProvider(
            create: (context) => CreateStoriesCubit(apiClient),
          ),
          BlocProvider(
            create: (context) => ViewStoriesCubit(apiClient),
          ),
          BlocProvider(
            create: (context) => StoriesCubit(apiClient),
          ),
          BlocProvider(
            create: (context) => NewGroupCubit(apiClient),
          ),
          BlocProvider(
            create: (context) => NewGroupUiCubit(),
          ),
          BlocProvider(
            create: (context) => ConfigCubit(apiClient),
          ),
          BlocProvider(
            create: (context) => AdsConfigCubit(apiClient, dbHelper),
          ),
          BlocProvider(
            create: (context) => BannerLoadCubit(),
          ),
          BlocProvider(
            create: (context) => ConnectivityCubit(),
          ),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final connectionRouteObserver = ConnectionRouteObserver();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageChangeProvider>(
      create: (context) => LanguageChangeProvider(),
      child: Consumer<LanguageChangeProvider>(
          builder: (context, languageProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return BlocBuilder<ThemeCubit, ThemeData>(
                builder: (context, themeState) {
              return BlocListener<ConnectivityCubit, ConnectivityState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status,
                listener: (context, state) {
                  if (state.status == ConnectivityStatus.disconnected) {
                    if (!connectionRouteObserver.isConnectionScreenOpen) {
                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (_) => const ConnectionLostScreen(),
                          settings:
                              const RouteSettings(name: '/connection_lost'),
                        ),
                      );
                    }
                  } else if (state.status == ConnectivityStatus.connected) {
                    if (connectionRouteObserver.isConnectionScreenOpen &&
                        (navigatorKey.currentState?.canPop() ?? false)) {
                      navigatorKey.currentState?.pop();
                    }
                  }
                },
                child: GlobalLoaderOverlay(
                  overlayColor: Colors.transparent,
                  overlayWidgetBuilder: (_) {
                    return const CustomLoader();
                  },
                  child: MaterialApp(
                      debugShowCheckedModeBanner: false,
                      // debugShowCheckedModeBanner: Utils.isDebug ? true : false,
                      title: AppConstants.appName,
                      // theme: themeState,
                      // darkTheme: themeState,
                      // theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: ThemeMode.dark,
                      theme: ThemeData(
                        bottomSheetTheme: BottomSheetThemeData(
                          backgroundColor:
                              AppColors.dialogBg, // Set bottom sheet color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                        ),
                      ),
                      navigatorKey: navigatorKey,
                      localizationsDelegates: [
                        S.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: S.delegate.supportedLocales,
                      locale: Provider.of<LanguageChangeProvider>(context)
                          .currentLocal,
                      home: SplashScreen(),
                      navigatorObservers: [connectionRouteObserver],
                      // onUnknownRoute: (settings) => MaterialPageRoute(
                      //   builder: (_) => SplashScreen(),
                      // ),
                      builder: EasyLoading.init(
                        builder: (context, child) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Utils.hideKeyboardGlobally();
                          });
                          return CustomAnnotatedRegions(
                            child: Scaffold(
                              resizeToAvoidBottomInset: false,
                              body: SafeArea(
                                top: false,
                                child: GestureDetector(
                                  onTap: () {
                                    Utils.hideKeyboardInApp(context);
                                  },
                                  child: child,
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                ),
              );
            });
          },
        );
      }),
    );
  }
}
