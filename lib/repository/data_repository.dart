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

  Future<void> deleteNode(NodeId nodeId) async {
    print('Deleting node ${nodeId}');
    await apiService.deleteNode(nodeId);
    print('Deleted node ${nodeId}');
  }

  Future<Node> addNewNode(NodeId parentId, int position) async {
    print('Adding new node to $parentId at position $position');
    var newNode = await apiService.addNode(parentId, position);
    print('Added new node ${newNode.id}');
    return newNode;
  }

  Future<void> moveNode(
      NodeId nodeId, NodeId newParentId, int newPosition) async {
    print('Moving node ${nodeId} to ${newParentId} at position ${newPosition}');
    await apiService.moveNode(nodeId, newParentId, newPosition);
    print('Moved node ${nodeId} to ${newParentId} at position ${newPosition}');
  }
}
