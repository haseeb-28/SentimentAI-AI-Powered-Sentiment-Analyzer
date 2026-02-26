import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/analysis_history.dart';

class StorageService {
  static const String _boxName = 'analysis_history';
  static const int _maxHistoryItems = 100;

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<List<AnalysisHistory>> getHistory() async {
    try {
      final box = await _openBox();
      final items = box.values.map((e) {
        if (e is String) {
          return AnalysisHistory.fromJson(jsonDecode(e));
        } else if (e is Map) {
          return AnalysisHistory.fromJson(Map<String, dynamic>.from(e));
        } else {
          return null;
        }
      }).whereType<AnalysisHistory>().toList();
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveAnalysis(AnalysisHistory analysis) async {
    try {
      final box = await _openBox();
      await box.put(analysis.id, analysis.toJson());

      // Enforce max items by removing oldest
      if (box.length > _maxHistoryItems) {
        final all = await getHistory();
        final toRemove = all.skip(_maxHistoryItems).map((e) => e.id);
        for (final id in toRemove) {
          await box.delete(id);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> deleteAnalysis(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearHistory() async {
    try {
      final box = await _openBox();
      await box.clear();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<int> getHistoryCount() async {
    try {
      final box = await _openBox();
      return box.length;
    } catch (_) {
      final history = await getHistory();
      return history.length;
    }
  }
}



