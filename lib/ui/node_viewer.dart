import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/editor_webview.dart';
import 'package:provider/provider.dart';

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
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: toggleEditor,
          child: Icon(_isEditing ? Icons.save : Icons.edit),
        ),
      ),
    );
  }
}
