import 'package:flutter/services.dart';

class Platform {
  static const MethodChannel _channel = const MethodChannel('flutter_stripe_sdk');
  static Platform _instance = Platform._internal();

  Map<String, List<Future<dynamic> Function(dynamic arguments)>> _methodHandlers;

  Platform._internal() {
    _methodHandlers = Map();
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    if (_methodHandlers.containsKey(call.method)) {
      for (var handler in _methodHandlers[call.method]) {
        return await handler(call.arguments);
      }
    }
  }

  void registerMethodCallHandler(
      String method, Future<dynamic> Function(dynamic arguments) handler) {
    if (_methodHandlers.containsKey(method)) {
      if (!_methodHandlers[method].contains(handler)) {
        _methodHandlers[method].add(handler);
      }
    } else {
      _methodHandlers[method] = List();
      _methodHandlers[method].add(handler);
    }
  }

  void unregisterMethodCallHandler(
      String method, Future<dynamic> Function(dynamic arguments) handler) {
    if (_methodHandlers.containsKey(method)) {
      if (_methodHandlers[method].contains(handler)) {
        _methodHandlers[method].remove(handler);

        if (_methodHandlers[method].isEmpty) {
          _methodHandlers.remove(method);
        }
      }
    }
  }

  static MethodChannel get channel => _channel;
  static Platform get instance => _instance;
}
