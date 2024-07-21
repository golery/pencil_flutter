// ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/models/tree_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/data_widget.dart';
import 'package:pencil_flutter/ui/node_viewer.dart';
import 'package:pencil_flutter/ui/select_book_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _showNodeViewer = false;
  Node? _node;

  void handleOpenNode(DataProvider dataProvider, Node node) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, b, c) {
            return NodeViewer(node: node);
          }),
    );
    dataProvider.rebuildListItems();
    await dataProvider.updateNode(node);
  }

  void handleSelectBook() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select a book'),
        ),
        body: const SelectBookScreen(),
      );
    }));
  }

  Widget getBody(DataProvider dataProvider) {
    void onOpenNode(Node node) {
      handleOpenNode(dataProvider, node);
    }

    void onAddNode(NodeId nodeId) {
      dataProvider.addNewNode(nodeId);
    }

    void onRemoveNode(NodeId nodeId) {
      dataProvider.deleteNode(nodeId);
    }

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              dataProvider.reorder(oldIndex, newIndex);
            },
            itemCount: dataProvider.treeListItems.length,
            itemBuilder: (context, index) {
              return Container(
                  key: ValueKey(dataProvider.treeListItems[index].nodeId),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFDADADA), width: 1.0),
                    ),
                  ),
                  child: DataWidget(
                    key: Key('${dataProvider.treeListItems[index].nodeId}'),
                    listItem: dataProvider.treeListItems[index],
                    treeModel: dataProvider,
                    onOpenNode: onOpenNode,
                    onAddNode: onAddNode,
                    onRemoveNode: onRemoveNode,
                  ));
            },
          ),
        ),
      ],
    );
  }

  void _refresh() async {
    await context.read<DataProvider>().loadBoook(3);
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        print('Rebuild home screen');
        if (dataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (dataProvider.errorMessage != null) {
          return Center(child: Text('Error: ${dataProvider.errorMessage}'));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: ElevatedButton(
                onPressed: handleSelectBook,
                child: Text(dataProvider.book?.name ?? ''),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: _refresh,
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: getBody(dataProvider),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Add your onPressed logic here
              },
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
