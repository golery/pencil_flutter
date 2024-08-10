// ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:provider/provider.dart';

class SelectBookScreen extends StatefulWidget {
  const SelectBookScreen({super.key});

  @override
  _SelectBookScreenState createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends State<SelectBookScreen> {
  Widget getBody(DataProvider dataProvider) {
    var books = dataProvider.bookList ?? [];
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.hardEdge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: InkWell(
              onTap: () async {
                await dataProvider.loadBoook(books[index].id);
                Navigator.pop(context);
              },
              child: SizedBox(
                  height: 50, child: Center(child: Text(books[index].name)))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(builder: (context, dataProvider, child) {
      return getBody(dataProvider);
    });
  }
}
