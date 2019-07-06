import 'package:flutter_stripe_sdk/ephemeral_key_update_listener.dart';

abstract class EphemeralKeyProvider {
  void createEphemeralKey(String apiVersion, EphemeralKeyUpdateListener keyUpdateListener);
}
