import 'dart:convert';
import 'dart:io' as io show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe_sdk/core/platform.dart';
import 'package:flutter_stripe_sdk/ephemeral_key_provider.dart';
import 'package:flutter_stripe_sdk/ephemeral_key_update_listener.dart';
import 'package:flutter_stripe_sdk/model/customer.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
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
      return Customer(
        id: result['id'],
      );
    } on PlatformException catch (e) {
      throw StripeException(int.parse(e.code), e.message, e.details);
    }
  }

  Future<Customer> updateCurrentCustomer() async {
    try {
      var result = await Platform.channel.invokeMethod('updateCurrentCustomer');
      return Customer(
        id: result['id'],
      );
    } on PlatformException catch (e) {
      throw StripeException(int.parse(e.code), e.message, e.details);
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods({@required PaymentMethodType type}) async {
    try {
      var result = await Platform.channel.invokeListMethod('getPaymentMethods', <String, dynamic>{
        'type': getStringFromPaymentMethodType(type),
      });

      return result.map((data) {
        return PaymentMethod(
          id: data['id'],
          created: data['created'],
          liveMode: data['liveMode'],
          type: data['type'],
          customerId: data['customerId'],
          metadata: data['metadata'],
        );
      }).toList();
    } on PlatformException catch (e) {
      throw StripeException(int.parse(e.code), e.message, e.details);
    }
  }

  Future<PaymentMethod> attachPaymentMethod({@required String id}) async {
    try {
      var result = await Platform.channel.invokeMethod('attachPaymentMethod', <String, dynamic>{
        'id': id,
      });

      return PaymentMethod(
        id: result['id'],
        created: result['created'],
        liveMode: result['liveMode'],
        type: result['type'],
        customerId: result['customerId'],
        metadata: result['metadata'],
      );
    } on PlatformException catch (e) {
      throw StripeException(int.parse(e.code), e.message, e.details);
    }
  }

  Future<PaymentMethod> detachPaymentMethod({@required String id}) async {
    try {
      var result = await Platform.channel.invokeMethod('detachPaymentMethod', <String, dynamic>{
        'id': id,
      });

      return PaymentMethod(
        id: result['id'],
        created: result['created'],
        liveMode: result['liveMode'],
        type: result['type'],
        customerId: result['customerId'],
        metadata: result['metadata'],
      );
    } on PlatformException catch (e) {
      throw StripeException(int.parse(e.code), e.message, e.details);
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
