// providers/data_provider.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/models/tree_model.dart';
import 'package:pencil_flutter/repository/data_repository.dart';

class DataProvider with ChangeNotifier {
  final DataRepository dataRepository;

  DataProvider({required this.dataRepository});
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Node> _nodes = [];
  Map<NodeId, Node> _nodeIdToNode = {};

  List<Node> get nodes => _nodes;

  List<TreeListItem> _treeListItems = [];
  List<TreeListItem> get treeListItems => _treeListItems;
  Map<NodeId, bool> _openMap = {};

  Book? _book;
  Book? get book => _book;

  List<Book>? _bookList;
  List<Book>? get bookList => _bookList;

  int? _bookId;

  void setBookId(int bookId) {
    this._bookId = bookId;
    notifyListeners();
  }

  Future<void> loadBoook(int bookId) async {
    this._bookId = bookId;

    List<Book> bookList;
    if (_bookList == null) {
      bookList = await dataRepository.fetchBookList();
      _bookList = bookList;
    } else {
      bookList = _bookList!;
    }

    final book = bookList.firstWhere((book) => book.id == bookId);
    this._book = book;

    _isLoading = true;
    _errorMessage = null;
    try {
      _nodes = await dataRepository.fetchNodes(bookId);
      for (var node in nodes) {
        _nodeIdToNode[node.id] = node;
      }

      _regenerateListItems(_nodes, book.rootId);
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addNodeToListItem(
      List<TreeListItem> listItems, NodeId nodeId, int level) {
    var node = _nodeIdToNode[nodeId];
    if (node == null) {
      print('Node not found $nodeId');
      return;
    }
    if (level >= 0) {
      bool? isOpen =
          node.children.length == 0 ? null : (_openMap[nodeId] ?? false);
      listItems.add(getTreeListItem(node, level, isOpen));
    }
    if (_openMap[nodeId] == true) {
      for (var childId in node.children) {
        _addNodeToListItem(listItems, childId, level + 1);
      }
    }
  }

  void rebuildListItems() {
    _regenerateListItems(_nodes, _book!.rootId);
  }

  void _regenerateListItems(List<Node> nodes, NodeId rootId) {
    var root = _nodeIdToNode[rootId];
    if (root == null) {
      throw Exception('Root node $rootId not found');
    }

    _openMap[rootId] = true;
    List<TreeListItem> listItem = [];
    _addNodeToListItem(listItem, root.id, -1);
    _treeListItems = listItem;
    notifyListeners();
  }

  void openNode(NodeId nodeId, bool open) {
    print('Open node $nodeId $open');
    _openMap[nodeId] = open;

    var rootId = this._book?.rootId;
    if (rootId == null) {
      print('No root Id');
      return;
    }
    rebuildListItems();
  }

  TreeListItem getTreeListItem(Node node, int level, bool? isOpen) {
    final title = node.title ?? node.name ?? '-';
    return TreeListItem(node.id, level, title, isOpen);
  }

  Node? findNodeByIdOpt(NodeId nodeId) {
    return _nodeIdToNode[nodeId];
  }

  Node getNodeById(NodeId nodeId) {
    final node = _nodeIdToNode[nodeId];
    if (node == null) {
      // throw exception
      throw Exception('Node not found $nodeId');
    }
    return node;
  }

  addNewNode(NodeId nodeId) async {
    Node parent = getNodeById(nodeId);
    Node newNode = await dataRepository.addNewNode(parent.id, 0);
    _nodes.add(newNode);
    _nodeIdToNode[newNode.id] = newNode;
    parent.children.insert(0, newNode.id);
    _openMap[nodeId] = true;
    print('Added node ${newNode.id}');
    rebuildListItems();
  }

  Node getParentNode(NodeId nodeId) {
    return nodes.firstWhere((node) => node.children.contains(nodeId));
  }

  List<NodeId> getDescendantsNodeId(NodeId nodeId) {
    List<NodeId> descendants = [nodeId];

    void _iterate(Node node, List<NodeId> descendants) {
      descendants.add(node.id);
      for (var childId in node.children) {
        var childNode = getNodeById(childId);
        _iterate(childNode, descendants);
      }
    }

    var node = getNodeById(nodeId);
    _iterate(node, descendants);
    return descendants;
  }

  deleteNode(NodeId nodeId) async {
    Node node = getNodeById(nodeId);

    // find parent of node node and remove its id from parent.children
    Node parent = getParentNode(nodeId);
    parent.children.remove(nodeId);

    var descendants = getDescendantsNodeId(nodeId);
    _nodes.removeWhere((n) => descendants.contains(n.id));
    _openMap.removeWhere((key, value) => descendants.contains(key));
    _nodeIdToNode.removeWhere((key, value) => descendants.contains(key));

    _regenerateListItems(nodes, _book!.rootId);

    await dataRepository.deleteNode(node.id);
    print('Deleted node ${node.id}');
  }

  updateNode(Node node) async {
    await dataRepository.updateNode(node);
  }

  reorder(int oldIndex, int newIndex) {
    var fromNode = _treeListItems[oldIndex];
    var fromParent = getParentNode(fromNode.nodeId);
    fromParent.children.remove(fromNode.nodeId);

    var toNode = _treeListItems[newIndex];
    var toParent = getParentNode(toNode.nodeId);
    var toChildIndex = toParent.children.indexOf(toNode.nodeId);
    toParent.children.insert(toChildIndex, fromNode.nodeId);
    rebuildListItems();
  }
}
