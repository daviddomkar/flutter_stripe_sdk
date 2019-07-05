import 'dart:async';

import 'package:flutter/services.dart';

class FlutterStripe {
  static const MethodChannel _channel = const MethodChannel('flutter_stripe');

  static String _publishableKey;
  static bool _initialized = false;

  static Future<void> init(String publishableKey) async {
    _publishableKey = publishableKey;
    await _channel.invokeListMethod('init', publishableKey);
    _initialized = true;
  }
}
