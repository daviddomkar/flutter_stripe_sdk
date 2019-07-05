import 'package:flutter_stripe/ephemeral_key_update_listener.dart';

abstract class EphemeralKeyProvider {
  void createEphemeralKey(String apiVersion, EphemeralKeyUpdateListener keyUpdateListener);
}
