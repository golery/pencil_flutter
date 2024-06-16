import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NodeViewer extends StatefulWidget {
  final Node node;

  const NodeViewer({Key? key, required this.node}) : super(key: key);

  @override
  NodeViewerState createState() => NodeViewerState();
}

class NodeViewerState extends State<NodeViewer> {
  WebViewController? _controller;

  Future<void> _load() async {
    var load = await WebViewCache.loadController(widget.node);

    setState(() {
      _controller = load;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewCache.getController();
    if (_controller == null) {
      _load();
    } else {
      _controller?.runJavaScript(
          "window.updateEditor({ node: ${jsonEncode(widget.node.toJson())}, edit: true});");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        // without delayed, it crashes to a blackscreen
        await Future.delayed(const Duration(milliseconds: 100));
        var contentNode = await _controller!
            .runJavaScriptReturningResult('window.getEditorContent();');
        print('Content of editor: ${contentNode}');
        if (contentNode is String) {
          Map<String, dynamic>? json = jsonDecode(contentNode);
          if (json != null) {
            widget.node.title = json['title'];
            widget.node.name = json['title'];
            widget.node.text = json['text'];
          }
        }

        if (!context.mounted) return;
        Navigator.of(context).pop(widget.node);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.node.title ?? 'Node'),
          ),
          body: Column(children: [
            Expanded(
              child: WebViewWidget(
                controller: _controller!,
              ),
            ),
            Row(children: [
              ElevatedButton(
                onPressed: () {
                  // _controller?.runJavaScript(
                  //     "window.SET_EDITOR_PROPS('Something here123');  ");
                  _load();
                },
                child: Text('Run JavaScript'),
              )
            ])
          ])),
    );
  }
}

class WebViewCache {
  static String? _htmlContent;
  static WebViewController? _controller;

  static Future<String> loadHtml() async {
    if (_htmlContent == null) {
      _htmlContent = await rootBundle.loadString('assets/webview/index.html');
    }
    return _htmlContent!;
  }

  static WebViewController? getController() {
    return _controller;
  }

  static Future<WebViewController> loadController(Node node) async {
    if (_controller == null) {
      _controller = WebViewController()
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
                  "window.updateEditor({ node: ${jsonEncode(node.toJson())}, edit: true});");
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
      await _controller!.enableZoom(false);
      await _controller!.loadHtmlString(await WebViewCache.loadHtml());
      _htmlContent = await rootBundle.loadString('assets/webview/index.html');
    }
    return _controller!;
  }
}
