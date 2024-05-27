typedef NodeId = int;

class TreeModel {
  final Map<NodeId, TreeNode> _map;
  final Map<NodeId, bool> _openMap = {};
  final Map<NodeId, NodeId> _parentMap;

  final List<TreeNode> nodes;
  final NodeId rootId;

  TreeModel(this.nodes, this.rootId)
      : _map = _buildMap(nodes),
        _parentMap = _buildParentMap(nodes);

  List<TreeNode> getNodes() => nodes;

  NodeId getRootId() => rootId;

  TreeNode? findNode(NodeId id) => _map[id];

  bool isOpen(NodeId id) {
    if (id == rootId) {
      return true;
    }
    return _openMap[id] ?? false;
  }

  void setOpen(NodeId id, bool open) {
    _openMap[id] = open;
  }

  void addChild(TreeNode parent, TreeNode newNode, int position) {
    final newNodeId = newNode.id;
    parent.children.clear();
    parent.children.insert(position, newNodeId);

    _map[newNodeId] = newNode;
    _parentMap[newNodeId] = parent.id;
    nodes.add(newNode);
  }

  void delete(NodeId id) {
    final parentId = getParentId(id);
    final parent = findById(parentId);

    if (parent == null) {
      throw Exception('Cannot find parent node $parentId');
    }

    final index = parent.children.indexOf(id);
    if (index >= 0) {
      print('Delete node from model $id');
      parent.children.removeAt(index);
    }
  }

  TreeNode? findById(NodeId? id) {
    if (id == null) {
      print('Undefined id');
      return null;
    }

    final node = _map[id];
    if (node == null) {
      print('Node $id not found');
    }
    return node;
  }

  NodeId? getParentId(NodeId childId) => _parentMap[childId];

  static Map<NodeId, TreeNode> _buildMap(List<TreeNode> nodes) {
    final map = <NodeId, TreeNode>{};
    for (var node in nodes) {
      map[node.id] = node;
    }
    return map;
  }

  static Map<NodeId, NodeId> _buildParentMap(List<TreeNode> nodes) {
    final map = <NodeId, NodeId>{};
    for (var node in nodes) {
      if (node.children != null) {
        for (var childId in node.children) {
          map[childId] = node.id;
        }
      }
    }
    return map;
  }
}

class TreeNode {
  final NodeId id;
  final String title;
  final List<NodeId> children;
  final NodeId? parentId;
  final String? text;

  TreeNode({
    required this.id,
    required this.title,
    required this.children,
    this.parentId,
    this.text,
  });
}

