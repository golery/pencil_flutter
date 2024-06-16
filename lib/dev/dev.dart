import 'package:flutter/material.dart';
import 'package:pencil_flutter/dev/dev_resuse_webview_with_router.dart';

class DevWidget extends StatelessWidget {
  const DevWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev'),
      ),
      body: const DevScreen(),
    );
  }
}
