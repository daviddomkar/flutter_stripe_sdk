import 'package:flutter/material.dart';

import 'package:flutter_stripe_sdk/stripe.dart';
import 'package:flutter_stripe_sdk/customer_session.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stripe _stripe;

  @override
  void initState() {
    super.initState();

    _stripe = Stripe('your_stripe_publishable_key');

    // Begin customer session
    CustomerSession.initCustomerSessionUsingFunction((apiVersion, keyUpdateListener) {
      // TODO Somehow get ephemeral key for customer form your backend

      // On success
      keyUpdateListener.onKeyUpdate('your ephemeral key json object');

      // On failure:
      keyUpdateListener.onKeyUpdateFailure(0, 'Cannot get ephemeral key');
    });
  }

  @override
  void dispose() {
    // End customer session
    CustomerSession.endCustomerSession();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(''),
        ),
      ),
    );
  }
}
