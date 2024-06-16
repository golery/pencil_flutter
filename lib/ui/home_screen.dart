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
    dataProvider.updateNode(node);
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
          child: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) => {},
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
                      onPressed: (node) {
                        handleOpenNode(dataProvider, node);
                      }));
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<DataProvider>().loadBoook(3);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        print('Rebuild home screen');
        if (dataProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (dataProvider.errorMessage != null) {
          return Center(child: Text('Error: ${dataProvider.errorMessage}'));
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

class _ModalState extends State<Modal> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              isVisible = false;
              setState(() {});
            },
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Add your onPressed logic here
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
          ),
        ],
      ),
    );
  }
}

class Modal extends StatefulWidget {
  const Modal({Key? key}) : super(key: key);

  @override
  _ModalState createState() => _ModalState();
}
