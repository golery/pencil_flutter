// ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/data_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (dataProvider.errorMessage != null) {
            return Center(child: Text('Error: ${dataProvider.errorMessage}'));
          } else if (dataProvider.data.isEmpty) {
            return Center(child: Text('No Data'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      dataProvider.fetchData();
                    },
                    child: Text('Add Data'),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: dataProvider.treeListItems.length,
                    itemBuilder: (context, index) {
                      return DataWidget(
                          listItem: dataProvider.treeListItems[index]);
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed logic here
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
