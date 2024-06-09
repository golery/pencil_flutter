import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DevScreen extends StatefulWidget {
  const DevScreen({Key? key}) : super(key: key);

  @override
  _DevScreenState createState() => _DevScreenState();
}

class _DevScreenState extends State<DevScreen> {
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
            height: 100vh;
            width: 100vw;
            overflow: hidden;
            display: flex;
            align-items: stretch;
            justify-content: stretch;
        }

        .root {
            display: flex;
            flex-grow: 1;
            border: 1px solid red;
            flex-direction: column;
        }

        .scroll {
            flex-grow: 1;
            overflow-y: scroll;
            border: 1px solid green;
        }
    </style>
    <script>
      alert(Math.random());
    </script>
</head>

<body>
    <div class="root">
        <h1>Welcome to the Full-Height Webpage</h1>
        <button onClick="FlutterEditorChannel.postMessage('Hello')">Post message</button>
        <div class="scroll">
            <h2>Welcome to the Full-Height Webpage323</h2>
        </div>
        <h1>END</h1>
    </div>
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
    await controller.loadFlutterAsset('assets/webview/index.html');
    // await controller.loadHtmlString(getHtml());
    // await controller.loadRequest(Uri.parse('https://flutter.dev'));
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

  int _flipCounter = 0;
  void _flip() {
    setState(() {
      ++_flipCounter;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Text('Loading');
    }

    Widget body = Text('Hello');
    if (_flipCounter % 2 == 1) {
      body = Expanded(
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
      ));
    }
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _flip();
          },
          child: Text('Flip'),
        ),
        body,
      ],
    );
  }
}
