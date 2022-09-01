import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  static const bannerId =
      'ca-app-pub-6050025830397443/3457914886';
      // 'ca-app-pub-3940256099942544/6300978111';
  static const nativeId =
      'ca-app-pub-6050025830397443/5700934842';
      // 'ca-app-pub-3940256099942544/2247696110';
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

  static NativeAdListener nativeAdListener(VoidCallback onAddloaded) =>
      NativeAdListener(
        onAdLoaded: (ad) => onAddloaded(),
        onAdClosed: (ad) => print('Native Ad closed ${ad.adUnitId}'),
        onAdClicked: (ad) => print('Native Ad clicked ${ad.adUnitId}'),
        onAdFailedToLoad: (ad, err) =>
            print('Native Ad failed to load ${ad.adUnitId} error: $err'),
        onAdImpression: (ad) => print('Native Ad impression ${ad.adUnitId}'),
        onAdOpened: (ad) => print('Native Ad opened ${ad.adUnitId}'),
        onAdWillDismissScreen: (ad) =>
            print('Native Ad dismissed ${ad.adUnitId}'),
        onNativeAdClicked: (ad) => print('Native Ad clicked ${ad.adUnitId}'),
      );
}
