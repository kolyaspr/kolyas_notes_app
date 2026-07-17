import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// Сервис для сохранения и загрузки заметок
class StorageService {
  static const String _storageKey = 'notes';

  /// Сохранить список заметок
  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((note) => note.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_storageKey, jsonString);
  }

  /// Загрузить список заметок
  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      return [];
    }
    
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}