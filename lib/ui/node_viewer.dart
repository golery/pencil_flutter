import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pencil_flutter/models/data_model.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/ui/editor_webview.dart';
import 'package:pencil_flutter/utils/constants.dart';
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
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: colorTagBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            color: colorTagText,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
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
  final FocusNode _tagFocusNode = FocusNode();

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
    _tagFocusNode.dispose();
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
      _tagFocusNode.unfocus();
    }
  }

  void _onTagInputChanged(String value) {
    // Only add tag when user types a space character (not comma, dot, colon, etc.)
    // Check if the last character is exactly a space
    if (value.isNotEmpty && value[value.length - 1] == ' ') {
      // Only create tag if the character before the space is alphanumeric
      // This prevents tag creation when Android keyboard auto-inserts space after punctuation
      if (value.length >= 2) {
        final charBeforeSpace = value[value.length - 2];
        final isWordChar = RegExp(r'[a-zA-Z0-9]').hasMatch(charBeforeSpace);

        if (!isWordChar) {
          // Space is preceded by punctuation, don't create tag
          return;
        }
      }

      // Get the tag text before the space (don't trim, as it might remove valid characters)
      final tag = value.substring(0, value.length - 1);
      if (tag.isNotEmpty && !widget.node.tags.contains(tag)) {
        setState(() {
          widget.node.tags.add(tag);
        });
        _tagController.clear();
        _saveTags();
        // Remove focus from the input field
        _tagFocusNode.unfocus();
      } else {
        // Clear the input if tag already exists or is empty
        _tagController.clear();
        // Remove focus from the input field
        _tagFocusNode.unfocus();
      }
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

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            final tag = controller.text.trim();
            if (tag.isNotEmpty && !widget.node.tags.contains(tag)) {
              setState(() {
                widget.node.tags.add(tag);
              });
              _saveTags();
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !widget.node.tags.contains(tag)) {
                setState(() {
                  widget.node.tags.add(tag);
                });
                _saveTags();
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
            child: Stack(
              children: [
                _editorWebView?.getWebViewWidget() ?? const SizedBox(),
                // Transparent overlay that captures taps when not editing
                if (!_isEditing)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        toggleEditor();
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Tags section at the bottom
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Minimum width needed for 5 characters (~60 pixels: 5 chars * 8px + padding)
                const minInputWidth = 60.0;
                final availableWidth = constraints.maxWidth;

                // Calculate approximate width taken by tags
                const charWidth = 8.0; // Approximate character width
                const badgePadding = 24.0; // Horizontal padding
                const spacing = 8.0; // Spacing between badges

                // Estimate width of tags on the first line
                double firstLineWidth = 0;
                for (var tag in widget.node.tags) {
                  final badgeWidth = (tag.length * charWidth) + badgePadding;
                  if (firstLineWidth + badgeWidth + spacing <=
                      availableWidth - minInputWidth) {
                    firstLineWidth += badgeWidth + spacing;
                  } else {
                    break; // Tags would wrap, so stop counting
                  }
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display existing tags as badges (left-aligned, can wrap)
                    Flexible(
                      flex: 0,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.node.tags.map((tag) {
                          return _TagBadge(
                            tag: tag,
                            onDelete: () => _removeTag(tag),
                          );
                        }).toList(),
                      ),
                    ),
                    // Add tag input or (+) button - dynamically switches based on available width
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, inputConstraints) {
                          // Check if the actual available width is below threshold
                          final actualWidth = inputConstraints.maxWidth;
                          if (actualWidth < minInputWidth) {
                            // Not enough space, show button instead
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: IconButton(
                                onPressed: _showAddTagDialog,
                                icon: const Icon(Icons.add),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                            );
                          }
                          // Enough space, show input field
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextField(
                              controller: _tagController,
                              focusNode: _tagFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'Add a tag',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13.0),
                              onChanged: _onTagInputChanged,
                              onSubmitted: (_) {
                                _addTag();
                                _tagFocusNode.unfocus();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
