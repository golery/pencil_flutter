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
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
