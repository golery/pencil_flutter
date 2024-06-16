// models/data_model.dart

import 'package:pencil_flutter/models/tree_model.dart';

class DataModel {
  final int id;
  final String name;
  final String description;

  DataModel({required this.id, required this.name, required this.description});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Book {
  final int id;
  final String code;
  final String name;
  final NodeId rootId;
  final int order;

  Book({
    required this.id,
    required this.code,
    required this.name,
    required this.rootId,
    required this.order,
  });

  @override
  String toString() {
    return 'Book{id: $id, code: $code, name: $name, rootId: $rootId, order: $order}';
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    try {
      return Book(
        id: json['id'],
        code: json['code'],
        name: json['name'],
        rootId: json['rootId'],
        order: json['order'],
      );
    } catch (e, stackTrace) {
      print('Failed to parse json: $json $e $stackTrace');
      rethrow;
    }
  }
}

class Node {
  final NodeId id;
  String? name;
  String? text;
  String? title;
  final List<NodeId> children;

  Node({
    required this.id,
    required this.name,
    required this.text,
    required this.title,
    required this.children,
  });

  @override
  String toString() {
    return 'Node{id: $id, name: $name, title: $title}';
  }

  factory Node.fromJson(Map<String, dynamic> json) {
    try {
      return Node(
          id: json['id'],
          name: json['name'],
          text: json['text'],
          title: json['title'],
          children: (json['children'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList() ??
              <int>[]);
    } catch (e, stackTrace) {
      print('Failed to parse json: $json $e $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'text': text,
      'title': title,
      'children': children,
    };
  }
}

class TreeListItem {
  final NodeId nodeId;
  final String title;
  final bool? isOpen;
  final int level;

  TreeListItem(this.nodeId, this.level, this.title, this.isOpen);

  @override
  String toString() {
    return 'TreeListItem{nodeId: $nodeId, title: $title, isOpen: $isOpen, level: $level}';
  }
}
