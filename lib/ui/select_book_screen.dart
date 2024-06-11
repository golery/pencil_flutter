// ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:provider/provider.dart';

class SelectBookScreen extends StatefulWidget {
  @override
  _SelectBookScreenState createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends State<SelectBookScreen> {
  Widget getBody(DataProvider dataProvider) {
    var books = dataProvider.bookList ?? [];
    return ListView.separated(
      itemCount: books.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(books[index].name!),
          onTap: () {
            dataProvider.setBook(books[index]);
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
