import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/saved_images_service.dart';
import 'result_screen.dart';

class SavedImagesScreen extends StatefulWidget {
  const SavedImagesScreen({super.key});

  @override
  State<SavedImagesScreen> createState() => _SavedImagesScreenState();
}

class _SavedImagesScreenState extends State<SavedImagesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = SavedImagesService.getSavedItems();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = SavedImagesService.getSavedItems();
    });
  }

  Future<void> _delete(String path) async {
    await SavedImagesService.deleteSavedPath(path);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9DDE3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Kayıtlarım",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5A3D44),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.pink.shade100,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user?.email ?? "Bilinmiyor",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Kayıtlar yüklenirken hata oluştu:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        "Henüz kayıt yok",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final file = File(item['path']);
                        return _buildCard(context, item, file);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Map<String, dynamic> item,
    File file,
  ) {
    final score = item['misleadingScore'];
    final risk = item['healthRisk'] ?? "bilinmiyor";
    final date = item['createdAt'] ?? "";
    final name = item['productName'] ?? "Analiz Edilen Ürün";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(imagePath: item['path']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBFC),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: file.existsSync()
                  ? Image.file(
                      file,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                    ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Analiz tarihi: ${_formatDate(date)}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),

                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E2D3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Yanıltıcılık skoru: $score",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _riskColor(risk).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Sağlık riski: ${risk.toUpperCase()}",
                      style: TextStyle(
                        color: _riskColor(risk),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => _delete(item['path']),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return "";
    final d = DateTime.tryParse(iso);
    if (d == null) return "";
    return "${d.day}.${d.month}.${d.year}";
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return Colors.green;
      case 'orta':
        return Colors.orange;
      case 'yüksek':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}