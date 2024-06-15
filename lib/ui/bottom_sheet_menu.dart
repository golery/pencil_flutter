import 'package:flutter/material.dart';

class BottomSheetMenu extends StatelessWidget {
  final Future<void> Function() onAdd;
  final Future<void> Function() onRemove;

  BottomSheetMenu({required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await onAdd();
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () async {
              await onRemove();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
