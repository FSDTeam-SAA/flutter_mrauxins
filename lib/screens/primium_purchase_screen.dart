import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/services/in_app_purchase_service.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/appbar.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';

// class PremiumScreen extends StatefulWidget {
//   @override
//   _PremiumScreenState createState() => _PremiumScreenState();
// }

// class _PremiumScreenState extends State<PremiumScreen> {
//   final InAppPurchaseService _iapService = InAppPurchaseService();
//   bool _isPremium = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPremiumStatus();
//   }

//   Future<void> _checkPremiumStatus() async {
//     bool premium = await _iapService.isPremiumUser();
//     setState(() {
//       _isPremium = premium;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(
//         isActionsShow: false,
//         isBackShow: true,
//         title: S.of(context).reportUserTitle,
//       ),
//       body: Center(
//         child: _isPremium
//             ? Text("You are a premium user. No ads!")
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text("Upgrade to Premium - No Ads!"),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () async {
//                       await _iapService.buyPremium();
//                       await _checkPremiumStatus();
//                     },
//                     child: Text("Buy Premium"),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       await _iapService.restorePurchases();
//                       await _checkPremiumStatus();
//                     },
//                     child: Text("Restore Purchase"),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final InAppPurchaseService _iapService = InAppPurchaseService();
  bool _isPremium = false;
  bool _isAdFree = false;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    bool premium = await _iapService.isPremiumUser();
    bool adFree = await _iapService.isAdFreeUser();
    setState(() {
      _isPremium = premium;
      _isAdFree = adFree;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        isActionsShow: false,
        isBackShow: true,
        title: S.of(context).premiumScreenTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isPremium) ...[
                Text(
                  S.of(context).premiumComingSoon,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ] else if (_isAdFree) ...[
                Text(
                  S.of(context).adFreeUserMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                CustomButton(
                    onPressed: () async {
                      await _iapService
                          .buyProduct(InAppPurchaseService.premiumProductId);
                      await _checkSubscriptionStatus();
                    },
                    child: Text(
                      S.of(context).upgradeToPremium,
                      style: AppTextStyles.medium(
                        fontSize: 16.sp,
                        color: AppColors.white,
                      ),
                    )),
              ]
              // else
              // ...[
              //   Text(
              //     S.of(context).noSubscriptionMessage,
              //     textAlign: TextAlign.center,
              //     style: TextStyle(fontSize: 18),
              //   ),
              //   SizedBox(height: 20),
              //   CustomButton(
              //       onPressed: () async {
              //         await _iapService
              //             .buyProduct(InAppPurchaseService.adFreeProductId);
              //         await _checkSubscriptionStatus();
              //       },
              //       child: Text(
              //         S.of(context).buyAdFree,
              //         style: AppTextStyles.medium(
              //           fontSize: 16.sp,
              //           color: AppColors.white,
              //         ),
              //       )),
              //   SizedBox(height: 10),
              //   CustomButton(
              //     onPressed: () async {
              //       await _iapService
              //           .buyProduct(InAppPurchaseService.premiumProductId);
              //       await _checkSubscriptionStatus();
              //     },
              //     child: Text(
              //       S.of(context).buyPremium,
              //       style: AppTextStyles.medium(
              //         fontSize: 16.sp,
              //         color: AppColors.white,
              //       ),
              //     ),
              //   ),
              // ]
              ,
              SizedBox(height: 20),
              // TextButton(
              //   onPressed: () async {
              //     await _iapService.restorePurchases();
              //     await _checkSubscriptionStatus();
              //   },
              //   child: Text(
              //     S.of(context).restorePurchase,
              //     style: AppTextStyles.medium(
              //       fontSize: 16.sp,
              //       color: AppColors.purpleText,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
