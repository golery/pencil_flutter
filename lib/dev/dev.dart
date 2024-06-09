import 'package:flutter/material.dart';
import 'package:pencil_flutter/dev/dev_resuse_webview.dart';

class DevWidget extends StatelessWidget {
  const DevWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DevScreen(),
    );
  }
}
