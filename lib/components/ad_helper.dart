import 'dart:io';

import 'package:quiz_app/constants.dart';



class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return bannerAndroid;
    } else if (Platform.isIOS) {
      return banneriOS;
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return InterstitialBannerAndroid;
    } else if (Platform.isIOS) {
      return InterstitialBanneriOS;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return rewardBannerAndroid;
    } else if (Platform.isIOS) {
      return rewardBanneriOS;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
