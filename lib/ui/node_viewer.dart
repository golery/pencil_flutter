import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/editor_webview.dart';
import 'package:provider/provider.dart';

// Custom badge widget for tags
class _TagBadge extends StatelessWidget {
  final String tag;
  final VoidCallback onDelete;

  const _TagBadge({
    required this.tag,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6.0),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              size: 16.0,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class NodeViewer extends StatefulWidget {
  final Node node;
  // After a new node is added, nodeview is opened in edit mode
  final bool isOpenInEditMode;

  const NodeViewer(
      {super.key, required this.node, required this.isOpenInEditMode});

  @override
  NodeViewerState createState() => NodeViewerState();
}

class NodeViewerState extends State<NodeViewer> {
  EditorWebView? _editorWebView;
  bool _isEditing = false;
  late Node parent;
  final TextEditingController _tagController = TextEditingController();

  Future<void> _load() async {
    var load = await EditorWebView.load(onEditorReady: (editor) async {
      _isEditing = widget.isOpenInEditMode;
      await editor.updateEditor(widget.node, widget.isOpenInEditMode);
    });

    setState(() {
      _editorWebView = load;
    });
  }

  @override
  void initState() {
    super.initState();

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    parent = dataProvider.getParentNode(widget.node.id);

    _isEditing = widget.isOpenInEditMode;
    _load();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !widget.node.tags.contains(tag)) {
      setState(() {
        widget.node.tags.add(tag);
      });
      _tagController.clear();
      _saveTags();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      widget.node.tags.remove(tag);
    });
    _saveTags();
  }

  Future<void> _saveTags() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.updateNode(widget.node);
  }

  @override
  Widget build(BuildContext context) {
    if (_editorWebView == null) {
      return const Center(child: CircularProgressIndicator());
    }

    saveAndCloseEditor() async {
      var contentNode = await _editorWebView?.getEditorContent();
      print('[EDITOR] Content of editor: $contentNode');
      if (contentNode is String) {
        Map<String, dynamic>? json = jsonDecode(contentNode);
        if (json == null) {
          print('[EDITOR] Failed update. Null json');
        } else if (json['id'] == widget.node.id) {
          widget.node.title = json['title'];
          widget.node.name = json['title'];
          widget.node.text = json['text'];
        } else {
          print('[EDITOR]Failed update. Node mismtach ${widget.node}');
        }
      }
      // Save tags when closing editor
      await _saveTags();
      _editorWebView?.setEdit(false);

      setState(() {
        _isEditing = false;
      });
    }

    toggleEditor() async {
      if (!_isEditing) {
        _editorWebView?.setEdit(true);
        setState(() {
          _isEditing = true;
        });
      } else {
        await saveAndCloseEditor();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        // without delayed, it crashes to a blackscreen
        await Future.delayed(const Duration(milliseconds: 100));

        if (_isEditing) {
          await saveAndCloseEditor();
        }
        if (!context.mounted) return;
        Navigator.of(context).pop(widget.node);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit' : (parent.title ?? 'Node')),
        ),
        body: Column(children: [
          Expanded(
            child: _editorWebView?.getWebViewWidget(),
          ),
          // Tags section at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Display existing tags as badges
                ...widget.node.tags.map((tag) {
                  return _TagBadge(
                    tag: tag,
                    onDelete: () => _removeTag(tag),
                  );
                }),
                // Add tag input inline
                Container(
                  constraints:
                      const BoxConstraints(minWidth: 120, maxWidth: 200),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13.0),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add, size: 18),
                    padding: const EdgeInsets.all(6.0),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: toggleEditor,
          child: Icon(_isEditing ? Icons.save : Icons.edit),
        ),
      ),
    );
  }
}
