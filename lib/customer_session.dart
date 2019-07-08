import 'dart:convert';
import 'dart:io' as io show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_stripe_sdk/core/platform.dart';
import 'package:flutter_stripe_sdk/ephemeral_key_provider.dart';
import 'package:flutter_stripe_sdk/ephemeral_key_update_listener.dart';
import 'package:flutter_stripe_sdk/model/customer.dart';
import 'package:flutter_stripe_sdk/stripe.dart';
import 'package:flutter_stripe_sdk/stripe_error.dart';
import 'package:flutter_stripe_sdk/stripe_exception.dart';

class CustomerSession {
  static CustomerSession _instance;

  static CustomerSession get instance {
    if (_instance == null) {
      throw new Exception(
          "Attempted to get instance of PaymentConfiguration without initialization.");
    }

    return _instance;
  }

  static Future<void> initCustomerSession(EphemeralKeyProvider keyProvider) async {
    _instance = CustomerSession._internal(keyProvider);
    await Platform.channel.invokeMethod('initCustomerSession');
  }

  static Future<void> initCustomerSessionUsingFunction(
      Function(String apiVersion, EphemeralKeyUpdateListener keyUpdateListener)
          createEphemeralKeyFunction) async {
    await initCustomerSession(_FunctionEphemeralKeyProvider(createEphemeralKeyFunction));
  }

  static Future<void> endCustomerSession() async {
    _instance._dispose();
    await Platform.channel.invokeMethod('endCustomerSession');
    _instance = null;
  }

  EphemeralKeyProvider _keyProvider;
  EphemeralKeyUpdateListener _ephemeralKeyUpdateListener;

  CustomerSession._internal(EphemeralKeyProvider keyProvider) {
    _keyProvider = keyProvider;
    _ephemeralKeyUpdateListener = _EphemeralKeyUpdateListener();
    Platform.instance
        .registerMethodCallHandler('createEphemeralKey', _onPlatformCreateEphemeralKey);
  }

  Future<Customer> retrieveCurrentCustomer() async {
    try {
      var result = await Platform.channel.invokeMethod('retrieveCurrentCustomer');
      print(result);

      return Customer();
    } on PlatformException catch (e) {
      throw StripeException(int.parse(e.code), e.message, e.details as StripeError);
    }
  }

  Future<void> _onPlatformCreateEphemeralKey(dynamic arguments) async {
    if (_keyProvider != null) {
      _keyProvider.createEphemeralKey(arguments['apiVersion'], _ephemeralKeyUpdateListener);
    }
  }

  void _dispose() {
    _keyProvider = null;
    Platform.instance
        .unregisterMethodCallHandler('createEphemeralKey', _onPlatformCreateEphemeralKey);
  }
}

class _EphemeralKeyUpdateListener extends EphemeralKeyUpdateListener {
  @override
  void onKeyUpdate(dynamic stripeResponseJson) {
    Platform.channel.invokeMethod('onKeyUpdate', <String, dynamic>{
      'stripeResponseJson':
          io.Platform.isAndroid ? jsonEncode(stripeResponseJson) : stripeResponseJson,
    });
  }

  @override
  void onKeyUpdateFailure(int responseCode, String message) {
    Platform.channel.invokeMethod('onKeyUpdateFailure', <String, dynamic>{
      'responseCode': responseCode,
      'message': message,
    });
  }
}

class _FunctionEphemeralKeyProvider extends EphemeralKeyProvider {
  _FunctionEphemeralKeyProvider(this._createEphemeralKeyFunction);

  final Function(String apiVersion, EphemeralKeyUpdateListener keyUpdateListener)
      _createEphemeralKeyFunction;

  @override
  void createEphemeralKey(String apiVersion, EphemeralKeyUpdateListener keyUpdateListener) {
    _createEphemeralKeyFunction(apiVersion, keyUpdateListener);
  }
}
