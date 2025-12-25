// services/share_handler.dart

import 'package:flutter/services.dart';

class ShareHandler {
  static const MethodChannel _channel = MethodChannel('com.example.pencil_flutter/share');

  static ShareHandler? _instance;
  Function(String)? _onShareText;
  Function(String)? _onShareImage;

  ShareHandler._();

  static ShareHandler get instance {
    _instance ??= ShareHandler._();
    return _instance!;
  }

  /// Initialize the share handler and set up method call handler
  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from Android
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onShareText':
        final String? text = call.arguments as String?;
        if (text != null && _onShareText != null) {
          _onShareText!(text);
        }
        break;
      case 'onShareImage':
        final String? imageUri = call.arguments as String?;
        if (imageUri != null && _onShareImage != null) {
          _onShareImage!(imageUri);
        }
        break;
      default:
        break;
    }
  }

  /// Set callback for when text/URL is shared
  void setOnShareText(Function(String) callback) {
    _onShareText = callback;
  }

  /// Set callback for when image is shared
  void setOnShareImage(Function(String) callback) {
    _onShareImage = callback;
  }

  /// Clear callbacks
  void clearCallbacks() {
    _onShareText = null;
    _onShareImage = null;
  }
}

