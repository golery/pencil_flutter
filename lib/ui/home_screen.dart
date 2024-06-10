// ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/data_widget.dart';
import 'package:pencil_flutter/ui/node_viewer.dart';
import 'package:pencil_flutter/ui/select_book_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNodeViewer = false;
  Node? _node;

  void handleOpenNode(Node node) {
    Navigator.push(
      context,
      PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, b, c) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(node.title ?? 'Node'),
                ),
                body: Column(children: [
                  Expanded(child: NodeViewer(node: node)),
                ]));
          }),
    );
  }

  void handleSelectBook() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Select a book'),
        ),
        body: SelectBookScreen(),
      );
    }));
  }

  Widget getBody(DataProvider dataProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: dataProvider.treeListItems.length,
            itemBuilder: (context, index) {
              return DataWidget(
                  listItem: dataProvider.treeListItems[index],
                  onPressed: handleOpenNode);
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<DataProvider>().fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (dataProvider.errorMessage != null) {
          return Center(child: Text('Error: ${dataProvider.errorMessage}'));
        } else if (dataProvider.data.isEmpty) {
          return Center(child: Text('No Data'));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: ElevatedButton(
                onPressed: handleSelectBook,
                child: Text(dataProvider.book?.name ?? ''),
              ),
            ),
            body: getBody(dataProvider),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Add your onPressed logic here
              },
              child: Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
