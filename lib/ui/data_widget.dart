// ui/widgets/data_widget.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/bottom_sheet_menu.dart';
import 'package:pencil_flutter/ui/node_viewer.dart';
import 'package:provider/provider.dart';

final GlobalKey<NodeViewerState> _formKey = GlobalKey<NodeViewerState>();

class DataWidget extends StatelessWidget {
  final TreeListItem listItem;
  final void Function(Node)? onPressed;
  final DataProvider treeModel;
  const DataWidget(
      {required super.key,
      required this.listItem,
      this.onPressed,
      required this.treeModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 0,
      contentPadding: const EdgeInsets.all(0),
      leading: Padding(
        padding: EdgeInsets.only(left: listItem.level * 30),
        child: IconButton(
          icon: listItem.isOpen == null
              ? const SizedBox.shrink()
              : Icon(
                  listItem.isOpen! ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: Colors.grey),
          onPressed: () {
            if (listItem.isOpen == null) {
              print('Cannot open node');
              return;
            }
            // print('Node open $listItem');
            // Get the TreeModelProvider from the nearest Provider<TreeModel>.
            treeModel.openNode(listItem.nodeId, !listItem.isOpen!);
          },
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheetMenu(
                  onAdd: () async => {treeModel.addNewNode(listItem.nodeId)},
                  onRemove: () async =>
                      {treeModel.deleteNode(listItem.nodeId)});
            },
            isDismissible: true,
          );
        },
      ),
      title: GestureDetector(
        onTap: () {
          final treeModel = Provider.of<DataProvider>(context, listen: false);
          final node = treeModel.findNodeByIdOpt(listItem.nodeId);
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
