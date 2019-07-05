import 'package:flutter_stripe/api_key_validator.dart';

class PaymentConfiguration {
  static PaymentConfiguration _instance;

  static PaymentConfiguration get instance {
    if (_instance == null) {
      throw new Exception(
          "Attempted to get instance of PaymentConfiguration without initialization.");
    }

    return _instance;
  }

  String _publishableKey;

  PaymentConfiguration._internal(String publishableKey) {
    _publishableKey = ApiKeyValidator.instance.requireValid(publishableKey);
  }

  static void init(String publishableKey) {
    _instance = PaymentConfiguration._internal(publishableKey);
  }

  String get publishableKey => _publishableKey;
}
