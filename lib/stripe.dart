import 'dart:async';

import 'package:flutter_stripe_sdk/api_key_validator.dart';
import 'package:flutter_stripe_sdk/core/platform.dart';

class Stripe {
  bool _initialized = false;

  String _publishableKey;

  Future<void> _checkPlatformInit() async {
    if (!_initialized) {
      await Platform.channel.invokeMethod('init', <String, dynamic>{
        'publishableKey': _publishableKey,
      });
      _initialized = true;
    }
  }

  Stripe(String publishableKey) {
    _publishableKey = ApiKeyValidator.instance.requireValid(publishableKey);
    _checkPlatformInit();
  }
}
