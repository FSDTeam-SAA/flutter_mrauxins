import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:two_one_two_messenger/GoogleAds/Config.dart';
import 'package:two_one_two_messenger/GoogleAds/adsConfigController.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/main.dart';

class BannerAdManager extends StatefulWidget {
  const BannerAdManager({super.key});

  @override
  State<BannerAdManager> createState() => _BannerAdManagerState();
}

class _BannerAdManagerState extends State<BannerAdManager> with RouteAware {
  BannerAd? _bannerAd;
  AdManagerBannerAd? bannerAdAdx;
  bool isLoaded = false;
  bool showBanner = false;
  bool isAdmob = false;

  // The ad is a native platform view (white WebView). Routes are pushed as
  // non-opaque fade transitions, so a covered screen keeps compositing its
  // banner — and the white native view flashes through during keyboard
  // animations on the screen above. Unmount the AdWidget while covered.
  bool _coveredByRoute = false;

  @override
  void initState() {
    super.initState();
    showBannerCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    setState(() => _coveredByRoute = true);
  }

  @override
  void didPopNext() {
    setState(() => _coveredByRoute = false);
  }

  Future<void> showBannerCheck() async {
    showBanner = await Config().adsShow() == "on";
    isAdmob = await adsCubit.getBannerValue() == "admob";
    if (showBanner) {
      await loadAd();
    }
    setState(() {});
  }

  Future<void> loadAd() async {
    if (isAdmob) {
      _bannerAd = BannerAd(
        adUnitId: await Config().admobbannerAdUnitId(),
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            log('$ad loaded.');
            isLoaded = true;
            setState(() {});
          },
          onAdFailedToLoad: (ad, err) {
            log('BannerAd failed to load: $err');
            ad.dispose();
          },
        ),
      )..load();
    } else {
      bannerAdAdx = AdManagerBannerAd(
        adUnitId: await Config().adManagerbannerAdUnitId(),
        request: const AdManagerAdRequest(),
        sizes: [AdSize.banner],
        listener: AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            log('$ad loaded.');
            isLoaded = true;
            setState(() {});
          },
          onAdFailedToLoad: (ad, err) {
            log('BannerAd failed to load: $err');
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return showBanner && isLoaded && !_coveredByRoute
        ? BlocBuilder<AdsConfigCubit, AdsConfigState>(
            builder: (context, state) {
              if (!state.isLoading) {
                return isAdmob
                    ? SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      )
                    : SizedBox(
                        width: bannerAdAdx?.sizes[0].width.toDouble(),
                        height: bannerAdAdx?.sizes[0].height.toDouble(),
                        child: AdWidget(ad: bannerAdAdx!),
                      );
              }
              return const SizedBox();
            },
          )
        : const SizedBox();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return showBanner && isLoaded
  //       ? GetBuilder(
  //           init: adsConfigController,
  //           builder: (controller) => isAdmob
  //               ? SizedBox(
  //                   width: _bannerAd!.size.width.toDouble(),
  //                   height: _bannerAd!.size.height.toDouble(),
  //                   child: AdWidget(ad: _bannerAd!),
  //                 )
  //               : SizedBox(
  //                   width: bannerAdAdx?.sizes[0].width.toDouble(),
  //                   height: bannerAdAdx?.sizes[0].height.toDouble(),
  //                   child: AdWidget(ad: bannerAdAdx!),
  //                 ),
  //         )
  //       : const SizedBox();
  // }
}
