class ApiKeyValidator {
  static final ApiKeyValidator _instance = ApiKeyValidator._internal();
  static ApiKeyValidator get instance => _instance;

  ApiKeyValidator._internal();

  String requireValid(String apiKey) {
    if (apiKey == null || apiKey.trim().length == 0) {
      throw Exception("Invalid Publishable Key: " +
          "You must use a valid Stripe API key to make a Stripe API request. " +
          "For more info, see https://stripe.com/docs/keys");
    }

    if (apiKey.startsWith("sk_")) {
      throw Exception("Invalid Publishable Key: " +
          "You are using a secret key instead of a publishable one. " +
          "For more info, see https://stripe.com/docs/keys");
    }

    return apiKey;
  }
}
