// ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/data_widget.dart';
import 'package:pencil_flutter/ui/node_viewer.dart';
import 'package:provider/provider.dart';

class SelectBookScreen extends StatefulWidget {
  @override
  _SelectBookScreenState createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends State<SelectBookScreen> {
  bool _showNodeViewer = false;
  Node? _node;

  void handleOpenNode(Node node) {
    Navigator.push(
      context,
      PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, b, c) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(node.title ?? 'Node'),
                ),
                body: Column(children: [
                  Expanded(child: NodeViewer(node: node)),
                ]));
          }),
    );
  }

  Widget getBody(DataProvider dataProvider) {
    var books = dataProvider.bookList ?? [];
    return ListView.separated(
      itemCount: books.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(books[index].name!),
          onTap: () {
            Navigator.pop(context);
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(builder: (context, dataProvider, child) {
      return getBody(dataProvider);
    });
  }
}
