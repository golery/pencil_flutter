// providers/data_provider.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/models/tree_model.dart';
import 'package:pencil_flutter/repository/data_repository.dart';

class DataProvider with ChangeNotifier {
  final DataRepository dataRepository;

  DataProvider({required this.dataRepository});

  List<DataModel> _data = [
    DataModel(id: 12, name: 'Item 1', description: 'Description 1'),
    DataModel(id: 33, name: 'Item 2', description: 'Description 2'),
  ];

  bool _isLoading = false;
  String? _errorMessage;

  List<DataModel> get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Node> _nodes = [];
  List<Node> get nodes => _nodes;

  NodeId? _rootId;

  List<TreeListItem> _treeListItems = [];
  List<TreeListItem> get treeListItems => _treeListItems;
  Map<NodeId, bool> _openMap = {};
  Map<NodeId, Node> _nodeIdToNode = {};

  Book? _book;
  Book? get book => _book;
  List<Book>? bookList;

  void setBook(Book? book) {
    _book = book;
    notifyListeners();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    try {
      var books = await dataRepository.fetchBookList();
      print('Book list: $bookList');
      bookList = books;
      _book = books.firstWhere((book) => book.id == 3);
      if (_book == null) {
        throw Exception('Book not found');
      }
      Book book = _book!;
      print('Book: $book');
      _rootId = book.rootId;

      _nodes = await dataRepository.fetchNodes(3);
      for (var node in nodes) {
        _nodeIdToNode[node.id] = node;
      }

      process(_nodes, book.rootId);
      notifyListeners();
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

  void process(List<Node> nodes, NodeId rootId) {
    var root = _nodeIdToNode[rootId];
    if (root == null) {
      throw Exception('Root node $rootId not found');
    }

    _openMap[rootId] = true;
    List<TreeListItem> listItem = [];
    _addNodeToListItem(listItem, root.id, -1);
    _treeListItems = listItem;
  }

  void openNode(NodeId nodeId, bool open) {
    print('Open node $nodeId $open');
    _openMap[nodeId] = open;
    process(_nodes, _rootId!);
    notifyListeners();
  }

  TreeListItem getTreeListItem(Node node, int level, bool? isOpen) {
    final title = node.title ?? node.name ?? '-';
    return TreeListItem(node.id, level, title, isOpen);
  }

  Node? findNodeById(NodeId nodeId) {
    return _nodeIdToNode[nodeId];
  }
}
