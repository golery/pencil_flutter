// network/api_service.dart

import 'dart:convert';

import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/models/tree_model.dart';

import 'api_client.dart';

class ApiService {
  final ApiClient apiClient;

  ApiService({required this.apiClient});

  Future<List<DataModel>> fetchData() async {
    print('Start fetching data');
    final response = await apiClient.getRequest('/data');
    print('Done fetching data');
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DataModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Book>> fetchBookList() async {
    final response = await apiClient.getRequest('/api2/pencil/book');

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load book lists ${response.statusCode}');
    }
  }

  Future<List<Node>> fetchNodes(NodeId bookId) async {
    print('Fetch nodes for book');
    final response =
        await apiClient.getRequest('/api2/pencil/book/$bookId/node');
    print('Done.Fetch nodes for book');

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((node) => Node.fromJson(node)).toList();
    } else {
      throw Exception('Failed to load nodes');
    }
  }

  Future<void> updateNode(Node node) async {
    final response = await apiClient.postRequest('/api2/pencil/update', node);

    if (response.statusCode == 200) {
      print('Updated node. Response: ${response.body}');
      return;
    } else {
      throw Exception('Failed to update node ${node.id}');
    }
  }

  Future<Node> addNode(NodeId parentId, int position) async {
    final response = await apiClient.postRequest(
        '/api2/pencil/add/$parentId?position=$position', null);

    if (response.statusCode == 200) {
      print('Added node. Response: ${response.body}');
      return Node.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add node');
    }
  }

  Future<void> deleteNode(NodeId nodeId) async {
    final response =
        await apiClient.deleteRequest('/api2/pencil/delete/$nodeId');

    if (response.statusCode == 200) {
      print('Deleted node. Response: ${response.body}');
      return;
    } else {
      throw Exception('Failed to delete node $nodeId');
    }
  }

  Future<void> moveNode(
      NodeId nodeId, NodeId newParentId, int newPosition) async {
    var body = {'newParentId': newParentId, 'pos': newPosition};
    final response =
        await apiClient.postRequest('/api2/pencil/move/$nodeId', body);

    if (response.statusCode == 200) {
      print('Moved node. Response: ${response.body}');
      return;
    } else {
      throw Exception('Failed to move node $nodeId');
    }
  }
}
