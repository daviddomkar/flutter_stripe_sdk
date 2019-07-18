import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_stripe_sdk/api_key_validator.dart';
import 'package:flutter_stripe_sdk/core/platform.dart';
import 'package:flutter_stripe_sdk/model/card.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:flutter_stripe_sdk/model/payment_method_create_params.dart';
import 'package:flutter_stripe_sdk/stripe_exception.dart';

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

  // ignore: missing_return
  Future<PaymentMethod> createPaymentMethod(
      PaymentMethodCreateParams paymentMethodCreateParams) async {
    await _checkPlatformInit();

    try {
      switch (paymentMethodCreateParams.type) {
        case PaymentMethodCreateParamsType.Card:
          var result =
              await Platform.channel.invokeMethod('createPaymentMethodCard', <String, dynamic>{
            "cardNumber": paymentMethodCreateParams.card.number,
            "cardExpMonth": paymentMethodCreateParams.card.expMonth,
            "cardExpYear": paymentMethodCreateParams.card.expYear,
            "cardCvv": paymentMethodCreateParams.card.cvv,
            "billingDetailsName": paymentMethodCreateParams.billingDetails.name,
            "billingDetailsEmail": paymentMethodCreateParams.billingDetails.email,
          });

          // Map<String, dynamic> data = result as Map<String, dynamic>;

          print(result);

          return PaymentMethod(
            id: result['id'],
            created: result['created'] ?? null,
            liveMode: result['liveMode'] ?? null,
            type: result['type'] ?? null,
            customerId: result['customer'] ?? null,
            metadata: result['metadata'] ?? null,
            card: result['type'] == 'card'
                ? Card(
                    last4: result['card']['last4'],
                    brand: result['card']['brand'],
                  )
                : null,
          );
      }
    } on PlatformException catch (e) {
      throw StripeException(int.parse(e.code), e.message, e.details);
    }
  }
}
