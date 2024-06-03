import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NodeViewer extends StatefulWidget {
  const NodeViewer({Key? key}) : super(key: key);

  @override
  _NodeViewerState createState() => _NodeViewerState();
}

class _NodeViewerState extends State<NodeViewer> {
  String getHtml() {
    return '''
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <style>
            html,
            body {
                margin: 0;
                padding: 0;
                height: 100%;
                overflow: hidden;
            }

            body {
                display: flex;
                flex-direction: column;
            }
        </style>
    </head>

    <body>
        <h1>Welcome to the Full-Height Webpage</h1>
        <button onClick="FlutterEditorChannel.postMessage('Hello')">Post message</message>
    </body>

    </html>
    ''';
  }

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
            // _controller?.runJavaScript(
            //     "window.SET_EDITOR_PROPS('Something here123');  ");
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
    // await controller.loadFlutterAsset('assets/webview/index.html');
    await controller.loadHtmlString(getHtml());
    await controller.enableZoom(false);

    setState(() {
      _controller = controller;
    });
  }

  Future<void> _reload() async {
    print('a');
    await _controller?.loadHtmlString(getHtml());
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
        ElevatedButton(
          onPressed: () {
            // _controller?.runJavaScript(
            //     "window.SET_EDITOR_PROPS('Something here123');  ");
            _load();
          },
          child: Text('Run JavaScript'),
        ),
        Container(
          width: 300,
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
          child: SizedBox(
            width: 200,
            height: 200,
            child: WebViewWidget(
              controller: _controller!,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _load(),
          child: Text('Run JavaScript222'),
        ),
        ElevatedButton(
          onPressed: () => _reload(),
          child: Text('Reload'),
        ),
      ],
    );
  }
}
