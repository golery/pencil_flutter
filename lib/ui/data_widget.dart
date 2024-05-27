// ui/widgets/data_widget.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/node_viewer.dart';
import 'package:provider/provider.dart';

class DataWidget extends StatelessWidget {
  final TreeListItem listItem;

  DataWidget({required this.listItem});

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NodeViewer(key: ValueKey(listItem.nodeId)),
            ),
          );
        },
        child: Text(listItem.title),
      ),
    );
  }
}
