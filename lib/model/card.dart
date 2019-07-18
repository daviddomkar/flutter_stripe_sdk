import 'package:flutter_stripe_sdk/model/payment_method_create_params.dart';
import 'package:meta/meta.dart';

// TODO Validation

class Card {
  Card({
    this.number,
    this.cvv,
    this.expMonth,
    this.expYear,
    this.last4,
    this.brand,
  });

  final String number;
  final String cvv;
  final int expMonth;
  final int expYear;
  final String last4;
  final String brand;

  PaymentMethodCreateParamsCard toPaymentMethodParamsCard() {
    return PaymentMethodCreateParamsCard(
      number: number,
      cvv: cvv,
      expMonth: expMonth,
      expYear: expYear,
    );
  }
}
