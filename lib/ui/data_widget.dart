// ui/widgets/data_widget.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/models/tree_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/bottom_sheet_menu.dart';

const debugTapArea = false;

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
    // Icon size is typically 24.0 for default icons
    const double iconSize = 24.0;
    const double tapAreaWidth = iconSize * 3; // 3x the icon size
    const double minHeight = 48.0; // Standard Material list item height

    return Container(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: Stack(
        children: [
          // Main Content Row - defines the height of the Stack
          Row(
            children: [
              // Spacing for Indent + Icon + Gap
              // The text starts after the icon position
              SizedBox(width: listItem.level * 30 + iconSize + 8),

              // Title Text
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onOpenNode(listItem.nodeId);
                  },
                  behavior: HitTestBehavior
                      .translucent, // Catch clicks on whitespace around text
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0), // Vertical padding for text
                    color: Colors
                        .transparent, // Ensure hit test works on full area
                    child: Text(listItem.title,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ),
              ),

              // Trailing Icon
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomSheetMenu(
                          onAdd: () async => {onAddNode(listItem.nodeId)},
                          onRemove: () async =>
                              {onRemoveNode(listItem.nodeId)});
                    },
                    isDismissible: true,
                  );
                },
              ),
            ],
          ),

          // Leading Icon Overlay with expanded tap area
          if (listItem.isOpen != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0, // Full height
              width: listItem.level * 30 +
                  tapAreaWidth, // From left edge to overlap text
              child: GestureDetector(
                onTap: () {
                  treeModel.openNode(listItem.nodeId, !listItem.isOpen!);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: debugTapArea
                      ? Colors.blue.withValues(alpha: 0.2)
                      : null, // Debug: shows tap area
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                      left: listItem.level * 30), // Correct visual position
                  child: Icon(
                    listItem.isOpen!
                        ? Icons.arrow_drop_down
                        : Icons.arrow_right,
                    color: Colors.grey,
                    size: iconSize,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
