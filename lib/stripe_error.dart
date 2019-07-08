class StripeError {
  StripeError({this.type, this.message, this.code, this.param, this.declineCode, this.charge});

  // https://stripe.com/docs/api/errors (e.g. "invalid_request_error")
  final String type;
  final String message;

  // https://stripe.com/docs/error-codes (e.g. "payment_method_unactivated")
  final String code;
  final String param;

  // see https://stripe.com/docs/declines/codes
  final String declineCode;

  final String charge;
}
