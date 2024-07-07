import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NodeViewer extends StatefulWidget {
  final Node node;

  const NodeViewer({super.key, required this.node});

  @override
  NodeViewerState createState() => NodeViewerState();
}

class NodeViewerState extends State<NodeViewer> {
  WebViewController? _controller;
  bool _isEditing = false;

  Future<void> _load() async {
    var load = await WebViewCache.loadController(widget.node);

    setState(() {
      _controller = load;
    });
  }

  Future<void> _loadNode() async {
    print('[EDITOR] Display ${widget.node}');
    setState(() {
      _isEditing = false;
    });
    await _controller?.runJavaScript(
        "window.editor.updateEditor({ node: ${jsonEncode(widget.node.toJson())}, edit: false});");
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewCache.getController();
    if (_controller == null) {
      _load();
    } else {
      _loadNode();
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
            .runJavaScriptReturningResult('window.editor.getEditorContent();');
        print('[EDITOR] Content of editor: $contentNode');
        if (contentNode is String) {
          Map<String, dynamic>? json = jsonDecode(contentNode);
          if (json == null) {
            print('[EDITOR] Failed update. Null json');
          } else if (json['id'] == widget.node.id) {
            widget.node.title = json['title'];
            widget.node.name = json['title'];
            widget.node.text = json['text'];
          } else {
            print('[EDITOR]Failed update. Node mismtach ${widget.node}');
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
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              print('Set editing $_isEditing');
              _controller!.runJavaScriptReturningResult(
                  'window.editor.setEdit($_isEditing);');
            });
          },
          child: Icon(_isEditing ? Icons.done : Icons.edit),
        ),
      ),
    );
  }
}

class WebViewCache {
  static String? _htmlContent;
  static WebViewController? _controller;

  static Future<String> loadHtml() async {
    _htmlContent ??= await rootBundle.loadString('assets/webview/index.html');
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
          onMessageReceived: (JavaScriptMessage message) async {
            print('[WEBVIEW] Received message: ${message.message}');
            if (message.message == 'onEditorReady') {
              await _controller?.runJavaScript(
                  "window.updateEditor({ node: ${jsonEncode(node.toJson())}, edit: false});");
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
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
        ..setOnConsoleMessage((consoleMessage) {
          print('[EDITOR_CONSOLE]: ${consoleMessage.message}');
        });
      await _controller!.enableZoom(false);
      await _controller!.loadHtmlString(await WebViewCache.loadHtml());
      _htmlContent = await rootBundle.loadString('assets/webview/index.html');
    }
    return _controller!;
  }
}
