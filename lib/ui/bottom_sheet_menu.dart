import 'package:flutter/material.dart';

class BottomSheetMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add pressed')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              // Add your onPressed logic here
            },
          ),
        ],
      ),
    );
  }
}
