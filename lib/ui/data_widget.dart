// ui/widgets/data_widget.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/node_viewer.dart';
import 'package:provider/provider.dart';

final GlobalKey<NodeViewerState> _formKey = GlobalKey<NodeViewerState>();

class DataWidget extends StatelessWidget {
  final TreeListItem listItem;
  final void Function(Node)? onPressed;
  DataWidget({required this.listItem, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: EdgeInsets.only(left: listItem.level * 37),
        child: IconButton(
          icon: listItem.isOpen == null
              ? const SizedBox.shrink()
              : Icon(
                  listItem.isOpen! ? Icons.arrow_drop_down : Icons.arrow_right),
          onPressed: () {
            if (listItem.isOpen == null) {
              print('Cannot open node');
              return;
            }
            // print('Node open $listItem');
            // Get the TreeModelProvider from the nearest Provider<TreeModel>.
            final treeModel = Provider.of<DataProvider>(context, listen: false);
            treeModel.openNode(listItem.nodeId, !listItem.isOpen!);
          },
        ),
      ),
      title: GestureDetector(
        onTap: () {
          final treeModel = Provider.of<DataProvider>(context, listen: false);
          final node = treeModel.findNodeById(listItem.nodeId);
          if (node != null && onPressed != null) {
            onPressed!(node);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) {
            //       return NodeViewer(key: _formKey, node: node);
            //     },
            //   ),
            // );
          }
        },
        child: Text(listItem.title),
      ),
    );
  }
}
