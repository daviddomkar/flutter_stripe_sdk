import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:meta/meta.dart';

class PaymentMethodCreateParams {
  final PaymentMethodCreateParamsType type;
  final PaymentMethodCreateParamsCard card;
  final PaymentMethodBillingDetails billingDetails;
  final Map<String, String> metadata;

  PaymentMethodCreateParams._fromCard(
    PaymentMethodCreateParamsCard card, {
    PaymentMethodBillingDetails billingDetails,
    Map<String, String> metadata,
  })  : type = PaymentMethodCreateParamsType.Card,
        card = card,
        billingDetails = billingDetails,
        metadata = metadata;

  factory PaymentMethodCreateParams.create({
    @required PaymentMethodCreateParamsCard card,
    PaymentMethodBillingDetails billingDetails,
    Map<String, String> metadata,
  }) {
    return PaymentMethodCreateParams._fromCard(
      card,
      billingDetails: billingDetails,
      metadata: metadata,
    );
  }
}

class PaymentMethodCreateParamsCard {
  PaymentMethodCreateParamsCard({
    @required this.number,
    @required this.cvv,
    @required this.expMonth,
    @required this.expYear,
    this.name,
  });

  final String number;
  final String cvv;
  final int expMonth;
  final int expYear;
  final String name;
}

enum PaymentMethodCreateParamsType {
  Card,
  // TODO Ideal
}
