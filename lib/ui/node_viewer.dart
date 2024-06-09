import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NodeViewer extends StatefulWidget {
  final Node node;

  const NodeViewer({Key? key, required this.node}) : super(key: key);

  @override
  _NodeViewerState createState() => _NodeViewerState();
}

class _NodeViewerState extends State<NodeViewer> {
  WebViewController? _controller;

  Future<void> _load() async {
    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterEditorChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _controller?.runJavaScript(
                "window.updateEditor({ node: ${jsonEncode(widget.node.toJson())}, edit: true});");
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
      );
    await controller.loadFlutterAsset('assets/webview/index.html');
    // await controller.loadHtmlString(getHtml());
    // await controller.loadRequest(Uri.parse('https://flutter.dev'));
    await controller.enableZoom(false);

    setState(() {
      _controller = controller;
    });
  }

  Future<void> _reload() async {
    // print('a');
    // await _controller?.loadHtmlString(getHtml());
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Text('Loading');
    }

    return Column(
      children: [
        Expanded(
            child: Container(
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
          child: SizedBox(
            child: WebViewWidget(
              controller: _controller!,
            ),
          ),
        )),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // _controller?.runJavaScript(
                //     "window.SET_EDITOR_PROPS('Something here123');  ");
                _load();
              },
              child: Text('Run JavaScript'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _reload(),
              child: Text('Reload'),
            ),
          ],
        ),
      ],
    );
  }
}
