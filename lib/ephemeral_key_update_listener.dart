abstract class EphemeralKeyUpdateListener {
  void onKeyUpdate(String stripeResponseJson);
  void onKeyUpdateFailure(int responseCode, String message);
}
