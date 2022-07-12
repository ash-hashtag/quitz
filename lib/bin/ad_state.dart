import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  static const testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  static const nativeTestId = 'ca-app-pub-3940256099942544/2247696110';

  static const bannerId = 'ca-app-pub-6448660671908120/4361542873';

  static const nativeID = 'ca-app-pub-6448660671908120/3752837084';

  static final bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => print('Ad loaded ${ad.adUnitId}'),
    onAdClosed: (ad) => print('Ad closed ${ad.adUnitId}'),
    onAdClicked: (ad) => print('Ad clicked ${ad.adUnitId}'),
    onAdFailedToLoad: (ad, err) =>
        print('Ad failed to load ${ad.adUnitId} error: $err'),
    onAdImpression: (ad) => print('Ad impression ${ad.adUnitId}'),
    onAdOpened: (ad) => print('Ad opened ${ad.adUnitId}'),
    onAdWillDismissScreen: (ad) => print('Ad dismissed ${ad.adUnitId}'),
  );

  static nativeAdListener(VoidCallback onAddloaded) => NativeAdListener(
    onAdLoaded: (ad) => onAddloaded(),
    onAdClosed: (ad) => print('Native Ad closed ${ad.adUnitId}'),
    onAdClicked: (ad) => print('Native Ad clicked ${ad.adUnitId}'),
    onAdFailedToLoad: (ad, err) =>
        print('Native Ad failed to load ${ad.adUnitId} error: $err'),
    onAdImpression: (ad) => print('Native Ad impression ${ad.adUnitId}'),
    onAdOpened: (ad) => print('Native Ad opened ${ad.adUnitId}'),
    onAdWillDismissScreen: (ad) => print('Native Ad dismissed ${ad.adUnitId}'),
    onNativeAdClicked: (ad) => print('Native Ad clicked ${ad.adUnitId}'),
  );
}
