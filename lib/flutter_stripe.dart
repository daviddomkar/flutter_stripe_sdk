import 'dart:async';

import 'package:flutter/services.dart';

class FlutterStripe {
  static const MethodChannel _channel = const MethodChannel('flutter_stripe');

  static Future<void> init(String publishableKey) async {
    await _channel.invokeListMethod('init', publishableKey);
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
