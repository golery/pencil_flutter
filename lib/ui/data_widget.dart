// ui/widgets/data_widget.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/models/tree_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/bottom_sheet_menu.dart';
import 'package:pencil_flutter/ui/node_viewer.dart';
import 'package:provider/provider.dart';

final GlobalKey<NodeViewerState> _formKey = GlobalKey<NodeViewerState>();

class DataWidget extends StatelessWidget {
  final TreeListItem listItem;
  final void Function(NodeId) onOpenNode;
  final void Function(NodeId) onAddNode;
  final void Function(NodeId) onRemoveNode;
  final DataProvider treeModel;
  const DataWidget(
      {required super.key,
      required this.listItem,
      required this.onOpenNode,
      required this.onAddNode,
      required this.onRemoveNode,
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
                  onAdd: () async => {onAddNode(listItem.nodeId)},
                  onRemove: () async => {onRemoveNode(listItem.nodeId)});
            },
            isDismissible: true,
          );
        },
      ),
      title: GestureDetector(
        onTap: () {
          onOpenNode(listItem.nodeId);
        },
        child: Text(listItem.title),
      ),
    );
  }
}
