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
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 2),
            child: Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: InkWell(
                  splashColor: Colors.green.withAlpha(30),
                  onTap: () async {
                    await dataProvider.loadBoook(books[index].id);
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Row(children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.folder_outlined,
                            color: Color(0xFF37745B)),
                        const SizedBox(width: 10),
                        Text(books[index].name)
                      ]))),
            ));
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
