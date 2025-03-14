import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/note.dart';
import '../models/note_provider.dart';
import '../services/ai_service.dart';

class NoteScreen extends StatefulWidget {
  final bool isNewNote;
  final Note note;

  const NoteScreen({
    super.key,
    required this.isNewNote,
    required this.note,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _summaryController;
  late TextEditingController _tagController;
  late TabController _tabController;
  bool _isEditing = false;
  List<String> _keywords = [];
  List<String> _tags = [];
  bool _isLoadingKeywords = false;
  bool _isNewNote = false; // Add this variable
  
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _summaryController = TextEditingController(text: widget.note.summary ?? '');
    _tagController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tags = List.from(widget.note.tags);
    
    // Set editing mode if it's a new note
    _isEditing = widget.isNewNote;
    _isNewNote = widget.isNewNote; // Initialize our local state
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _tagController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final note = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      summary: _summaryController.text.isEmpty ? null : _summaryController.text,
      tags: _tags,
    );

    if (widget.isNewNote) {
      await Provider.of<NoteProvider>(context, listen: false).addNote(note);
    } else {
      await Provider.of<NoteProvider>(context, listen: false).updateNote(note);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _generateSummary() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content to your note first.'),
        ),
      );
      return;
    }

    // Save the current note first
    final note = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
    );

    if (_isNewNote) {
      await Provider.of<NoteProvider>(context, listen: false).addNote(note);
      setState(() {
        _isNewNote = false;
      });
    } else {
      await Provider.of<NoteProvider>(context, listen: false).updateNote(note);
    }

    // Generate summary
    try {
      await Provider.of<NoteProvider>(context, listen: false).generateSummary(note);
      
      if (!mounted) return;
      // Update the summary controller with the new summary
      final updatedNote = Provider.of<NoteProvider>(context, listen: false)
          .notes
          .firstWhere((n) => n.id == note.id);
      
      _summaryController.text = updatedNote.summary ?? '';
      
      // Switch to summary tab
      _tabController.animateTo(1);
      
      // Extract keywords
      _extractKeywords();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate summary: $e')),
      );
    }
  }

  Future<void> _extractKeywords() async {
    if (_contentController.text.isEmpty) return;
    
    setState(() {
      _isLoadingKeywords = true;
    });
    
    try {
      final keywords = await _aiService.extractKeywords(_contentController.text);
      setState(() {
        _keywords = keywords;
        _isLoadingKeywords = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingKeywords = false;
      });
      debugPrint('Error extracting keywords: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewNote ? 'New Note' : (_titleController.text.isEmpty ? 'Untitled Note' : _titleController.text)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveNote();
                setState(() {
                  _isEditing = false;
                });
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _generateSummary,
            tooltip: 'Generate Summary',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'tags') {
                _showTagsDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'tags',
                child: Row(
                  children: [
                    Icon(Icons.label_outline),
                    SizedBox(width: 8),
                    Text('Manage Tags'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Note'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          return Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  // Note Content Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none,
                          ),
                          style: Theme.of(context).textTheme.headlineSmall,
                          enabled: _isEditing,
                        ),
                        const Divider(),
                        Expanded(
                          child: _isEditing
                              ? TextField(
                                  controller: _contentController,
                                  decoration: const InputDecoration(
                                    hintText: 'Start typing...\nTip: Markdown formatting is supported!',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MarkdownBody(
                                        data: _contentController.text,
                                        selectable: true,
                                      ),
                                      if (_keywords.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        const Text('Keywords:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          children: _keywords.map((keyword) => Chip(
                                            label: Text(keyword),
                                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                            labelStyle: TextStyle(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                            ),
                                          )).toList(),
                                        ),
                                      ],
                                      if (_isLoadingKeywords) ...[
                                        const SizedBox(height: 16),
                                        const Center(child: CircularProgressIndicator()),
                                      ],
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Summary Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isEditing
                        ? TextField(
                            controller: _summaryController,
                            decoration: const InputDecoration(
                              hintText: 'No summary yet. Generate one using the magic wand button!',
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          )
                        : _summaryController.text.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No summary yet',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.auto_awesome),
                                      label: const Text('Generate Summary'),
                                      onPressed: _generateSummary,
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: MarkdownBody(
                                  data: _summaryController.text,
                                  selectable: true,
                                ),
                              ),
                  ),
                ],
              ),
              if (noteProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Generating summary...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _isEditing && _tabController.index == 0 
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_bold),
                      onPressed: () => _insertMarkdown('**', '**'),
                      tooltip: 'Bold',
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_italic),
                      onPressed: () => _insertMarkdown('_', '_'),
                      tooltip: 'Italic',
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_list_bulleted),
                      onPressed: () => _insertMarkdown('\n- ', ''),
                      tooltip: 'Bullet List',
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_list_numbered),
                      onPressed: () => _insertMarkdown('\n1. ', ''),
                      tooltip: 'Numbered List',
                    ),
                    IconButton(
                      icon: const Icon(Icons.title),
                      onPressed: () => _insertMarkdown('### ', ''),
                      tooltip: 'Heading',
                    ),
                    IconButton(
                      icon: const Icon(Icons.code),
                      onPressed: () => _insertMarkdown('`', '`'),
                      tooltip: 'Code',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showTagsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Tags'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new tag',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        _addTag(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_tagController.text),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: _tags.isEmpty
                    ? const Center(child: Text('No tags yet'))
                    : Wrap(
                        spacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  void _insertMarkdown(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    
    final beforeText = text.substring(0, selection.start);
    final selectedText = text.substring(selection.start, selection.end);
    final afterText = text.substring(selection.end);
    
    final newText = '$beforeText$prefix$selectedText$suffix$afterText';
    
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + suffix.length,
      ),
    );
  }
}
