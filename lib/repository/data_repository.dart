// repository/data_repository.dart

import 'package:pencil_flutter/api/api_service.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/models/tree_model.dart';

class DataRepository {
  final ApiService apiService;

  DataRepository({required this.apiService});

  Future<List<DataModel>> getData() async {
    return await apiService.fetchData();
  }

  Future<List<Book>> fetchBookList() async {
    return await apiService.fetchBookList();
  }

  Future<List<Node>> fetchNodes(NodeId bookId) async {
    return await apiService.fetchNodes(bookId);
  }

  Future<void> updateNode(Node node) async {
    print('Updating node ${node.id}: $node');
    await apiService.updateNode(node);
    print('Updated node ${node.id}');
  }
}
