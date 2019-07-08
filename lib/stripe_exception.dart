import 'package:flutter_stripe_sdk/stripe_error.dart';

class StripeException implements Exception {
  StripeException(this.errorCode, this.errorMessage, this.stripeError);

  final int errorCode;
  final String errorMessage;
  final dynamic stripeError;
}
