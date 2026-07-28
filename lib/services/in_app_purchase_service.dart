import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  static const String premiumProductId =
      'com.freshcodes.twoonetwomessenger.premium_upgrade';
  static const String adFreeProductId =
      'com.freshcodes.twoonetwomessenger.premium_no_ads';
  static const String _premiumKey = 'is_premium';
  static const String _adFreeKey = 'is_ad_free';

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> initialize() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) return;

      final response =
          await _iap.queryProductDetails({premiumProductId, adFreeProductId});
      _products = response.productDetails;

      _subscription = _iap.purchaseStream.listen((purchases) {
        _handlePurchaseUpdates(purchases);
      });

      await _verifyPurchaseStatus();
    } catch (e, st) {
      showMessage("Error in InAppPurchaseService => initialize: $e , $st");
    }
  }

  List<ProductDetails> get availableProducts => _products;

  Future<void> buyProduct(String productId) async {
    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
      );

      final purchaseParam = PurchaseParam(productDetails: product);
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e, st) {
      showMessage("Error in InAppPurchaseService => buyProduct: $e , $st");
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    try {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          if (purchase.productID == premiumProductId) {
            await _savePurchaseStatus(_premiumKey, true);
          } else if (purchase.productID == adFreeProductId) {
            await _savePurchaseStatus(_adFreeKey, true);
          }
        }
      }
    } catch (e, st) {
      showMessage(
          "Error in InAppPurchaseService => _handlePurchaseUpdates: $e , $st");
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e, st) {
      showMessage(
          "Error in InAppPurchaseService => restorePurchases: $e , $st");
    }
  }

  Future<bool> isPremiumUser() async {
    return AppPreference.getBoolean(_premiumKey) ?? false;
  }

  Future<bool> isAdFreeUser() async {
    return AppPreference.getBoolean(_adFreeKey) ?? false;
  }

  Future<void> _savePurchaseStatus(String key, bool status) async {
    await AppPreference.setBoolean(key, value: status);
  }

  Future<void> _verifyPurchaseStatus() async {
    await restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
