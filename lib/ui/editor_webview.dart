import 'package:pencil_flutter/models/data_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:pencil_flutter/utils/constants.dart';
import 'dart:convert';

class EditorWebView {
  static EditorWebView? _singleton;

  static Future<EditorWebView> load(
      {required Future<void> Function(EditorWebView) onEditorReady}) async {
    if (EditorWebView._singleton == null) {
      final EditorWebView webView = EditorWebView();
      await webView.init(onEditorReady: onEditorReady);
      EditorWebView._singleton = webView;
    } else {
      print('Reusing webview');
      await onEditorReady(EditorWebView._singleton!);
    }

    return EditorWebView._singleton!;
  }

  late WebViewController? _controller;

  Future<void> init({required Future<void> Function(EditorWebView) onEditorReady}) async {
    String htmlContent =
        await rootBundle.loadString('assets/webview/index.html');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          _controller!
              .runJavaScript("window.initEditor({ imageHost: '$imageHost'});");
        },
      ))
      ..addJavaScriptChannel(
        'FlutterEditorChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          print('[WEBVIEW] Received message: ${message.message}');
          if (message.message == 'onEditorReady') {
            await onEditorReady(this);
          }
        },
      )
      ..setOnConsoleMessage((consoleMessage) {
        print('[EDITOR_CONSOLE]: ${consoleMessage.message}');
      });
    await _controller!.enableZoom(false);
    await _controller!.loadHtmlString(htmlContent);
  }

  WebViewWidget getWebViewWidget() {
    return WebViewWidget(controller: _controller!);
  }

  void updateEditor(Node node, bool edit) {
    print('Update editor');
    _controller?.runJavaScript(
        "window.editor.updateEditor({ node: ${jsonEncode(node.toJson())}, edit: $edit});");
  }

  Future<Object>? getEditorContent() {
    return _controller
        ?.runJavaScriptReturningResult('window.editor.getEditorContent();');
  }

  void setEdit(bool edit) {
    _controller?.runJavaScriptReturningResult('window.editor.setEdit($edit);');
  }
}
