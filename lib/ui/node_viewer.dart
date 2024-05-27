import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NodeViewer extends StatefulWidget {
  const NodeViewer({Key? key}) : super(key: key);

  @override
  _NodeViewerState createState() => _NodeViewerState();
}

class _NodeViewerState extends State<NodeViewer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _controller.runJavaScript("alert('help2')");
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadFlutterAsset('assets/webview/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
