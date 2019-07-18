import 'package:meta/meta.dart';

import 'card.dart';

class PaymentMethod {
  PaymentMethod({
    @required this.id,
    this.created,
    this.liveMode,
    this.type,
    this.billingDetails,
    this.card,
    this.customerId,
    this.metadata,
  });

  final String id;
  final int created;
  final bool liveMode;
  final String type;

  // TODO Implement this
  final PaymentMethodBillingDetails billingDetails;
  final Card card;
  /*
  final CardPresent cardPresent;
  final Ideal ideal; */
  final String customerId;
  final Map<dynamic, dynamic> metadata;
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

class PaymentMethodBillingDetails {
  PaymentMethodBillingDetails({this.name, this.email});

  final String name;
  final String email;
}
