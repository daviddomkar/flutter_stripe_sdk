abstract class EphemeralKeyUpdateListener {
  void onKeyUpdate(dynamic stripeResponseJson);
  void onKeyUpdateFailure(int responseCode, String message);
}
