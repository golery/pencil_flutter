import 'package:flutter/material.dart';

class BottomSheetMenu extends StatelessWidget {
  final Future<void> Function() onAdd;
  final Future<void> Function() onRemove;

  const BottomSheetMenu(
      {super.key, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              size: 40,
            ),
            onPressed: () async {
              await onAdd();
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, size: 40),
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
