import 'package:flutter/foundation.dart';

import 'note.dart';
import '../services/database_helper.dart';
import '../services/ai_service.dart';

class NoteProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AIService _aiService = AIService();
  
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
  List<Note> get notes => _searchQuery.isEmpty ? _notes : _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    
    _notes = await _databaseHelper.getNotes();
    _applySearch();
    
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = _notes;
      return;
    }

    final searchLower = _searchQuery.toLowerCase();
    _filteredNotes = _notes.where((note) {
      return note.title.toLowerCase().contains(searchLower) || 
             note.content.toLowerCase().contains(searchLower) ||
             (note.summary != null && note.summary!.toLowerCase().contains(searchLower));
    }).toList();
  }

  Future<void> addNote(Note note) async {
    await _databaseHelper.insertNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _databaseHelper.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _databaseHelper.deleteNote(id);
    await loadNotes();
  }

  Future<void> generateSummary(Note note) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final summary = await _aiService.generateSummary(note.content);
      final updatedNote = note.copyWith(summary: summary);
      await updateNote(updatedNote);
      
      // Kiểm tra xem note có trong danh sách sau khi cập nhật không
      final noteExists = _notes.any((n) => n.id == note.id);
      if (!noteExists) {
        debugPrint('Warning: Note with ID ${note.id} not found after update');
        await loadNotes(); // Reload notes if there's an inconsistency
      }
    } catch (e) {
      debugPrint('Error generating summary: $e');
      rethrow; // Rethrow to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
