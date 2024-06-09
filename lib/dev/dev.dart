import 'package:flutter/material.dart';
import 'package:pencil_flutter/dev/node_viewer.dart';

class DevWidget extends StatelessWidget {
  const DevWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DevWebView(),
    );
  }
}
