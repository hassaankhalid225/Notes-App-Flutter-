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
  final UndoHistoryController _undoController = UndoHistoryController();
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
    _undoController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {
        _lastUpdated = DateTime.now();
      });
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
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
      displayOrder: widget.note?.displayOrder ?? 0,
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          _saveNote();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            ValueListenableBuilder<UndoHistoryValue>(
              valueListenable: _undoController,
              builder: (context, value, child) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo_rounded),
                      onPressed: value.canUndo ? () => _undoController.undo() : null,
                      tooltip: 'Undo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo_rounded),
                      onPressed: value.canRedo ? () => _undoController.redo() : null,
                      tooltip: 'Redo',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Hero(
          tag: 'note_${_noteId ?? 'new'}',
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.4)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          undoController: _undoController,
                          maxLines: null,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Start writing your amazing idea...',
                            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.4)),
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
      ),
    );
  }
}
