import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/db_helper.dart';
import '../models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  Timer? _debounce;
  late int? _noteId;
  bool _isNewNote = true;
  late DateTime _lastUpdated;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _noteId = widget.note!.id;
      _isNewNote = false;
      _lastUpdated = widget.note!.updatedAt;
    } else {
      _noteId = null;
      _lastUpdated = DateTime.now();
    }

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _lastUpdated = DateTime.now();
    });
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    final note = Note(
      id: _noteId,
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );

    if (_isNewNote) {
      final id = await _dbHelper.insertNote(note);
      if (!mounted) return;
      setState(() {
        _noteId = id;
        _isNewNote = false;
      });
    } else {
      await _dbHelper.updateNote(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _contentController.text.length;
    final wordCount = _contentController.text.isEmpty ? 0 : _contentController.text.trim().split(RegExp(r'\s+')).length;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          _saveNote();
        }
      },
      child: Hero(
        tag: 'note_${_noteId ?? 'new'}',
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!_isNewNote)
                IconButton(
                  tooltip: 'Delete Note',
                  icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: const Text('Discard Note?'),
                        content: const Text('This action cannot be undone. Are you sure?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No, keep it'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await _dbHelper.deleteNote(_noteId!);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              IconButton(
                tooltip: 'Share Note',
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing functionality coming soon!')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('MMMM d, h:mm a').format(_lastUpdated),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$wordCount words | $charCount chars',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        maxLines: null,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          height: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start writing your amazing idea...',
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                        autofocus: _isNewNote,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
