import 'package:meta/meta.dart';

class PaymentMethod {
  PaymentMethod({
    @required this.id,
    this.created,
    this.liveMode,
    this.type,
    this.customerId,
    this.metadata,
  });

  final String id;
  final int created;
  final bool liveMode;
  final String type;

  // TODO Implement this
  /* final BillingDetails billingDetails;
  final Card card;
  final CardPresent cardPresent;
  final Ideal ideal; */
  final String customerId;
  final Map<String, String> metadata;
}

enum PaymentMethodType { Card, CardPresent, Ideal }

// ignore: missing_return
String getStringFromPaymentMethodType(PaymentMethodType type) {
  switch (type) {
    case PaymentMethodType.Card:
      return "card";
    case PaymentMethodType.CardPresent:
      return "card_present";
    case PaymentMethodType.Ideal:
      return "ideal";
  }
}
