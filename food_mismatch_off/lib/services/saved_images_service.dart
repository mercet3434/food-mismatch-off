import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/analysis_result.dart';

class SavedImagesService {
  static const _baseKey = 'saved_images';

  static String _getUserKey() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı oturumu bulunamadı.');
    }

    return '${_baseKey}_${user.uid}';
  }

  static Future<String> saveToAppFolder(
    String sourcePath, {
    AnalysisResult? analysisResult,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Görsel kaydetmek için giriş yapılmış olmalı.');
    }

    final docs = await getApplicationDocumentsDirectory();
    final savedDir = Directory('${docs.path}/saved_images/${user.uid}');

    if (!await savedDir.exists()) {
      await savedDir.create(recursive: true);
    }

    final ext = _safeExt(sourcePath);
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final newPath = '${savedDir.path}/$fileName';

    final sourceFile = File(sourcePath);
    if (sourceFile.path != newPath) {
      await sourceFile.copy(newPath);
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey();
    final list = prefs.getStringList(key) ?? [];

    list.insert(
      0,
      jsonEncode({
        'path': newPath,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': user.uid,
        'email': user.email,
        'productName': analysisResult?.productName,
        'misleadingScore': analysisResult?.misleadingScore,
        'detectedVisuals': analysisResult?.detectedVisuals,
        'actualIngredients': analysisResult?.actualIngredients,
        'healthRisk': analysisResult?.healthRisk,
      }),
    );

    await prefs.setStringList(key, list);

    return newPath;
  }

  static Future<List<Map<String, dynamic>>> getSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey();
    final list = prefs.getStringList(key) ?? [];

    return list
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  static Future<List<String>> getSavedPaths() async {
    final items = await getSavedItems();
    return items.map((m) => m['path'] as String).toList();
  }

  static Future<void> updateAnalysisByPath(
    String path,
    AnalysisResult analysisResult,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey();
    final list = prefs.getStringList(key) ?? [];

    final updatedList = list.map((e) {
      final m = jsonDecode(e) as Map<String, dynamic>;

      if (m['path'] == path) {
        m['productName'] = analysisResult.productName;
        m['misleadingScore'] = analysisResult.misleadingScore;
        m['detectedVisuals'] = analysisResult.detectedVisuals;
        m['actualIngredients'] = analysisResult.actualIngredients;
        m['healthRisk'] = analysisResult.healthRisk;
      }

      return jsonEncode(m);
    }).toList();

    await prefs.setStringList(key, updatedList);
  }

  static Future<void> deleteSavedPath(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey();
    final list = prefs.getStringList(key) ?? [];

    list.removeWhere((e) {
      final m = jsonDecode(e) as Map<String, dynamic>;
      return m['path'] == path;
    });

    await prefs.setStringList(key, list);
  }

  static String _safeExt(String path) {
    final parts = path.split('.');
    if (parts.length < 2) return 'jpg';

    final ext = parts.last.toLowerCase();
    return ext.isEmpty ? 'jpg' : ext;
  }
}