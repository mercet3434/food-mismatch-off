import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'saved_images_screen.dart';
import 'camera_screen.dart';
import 'result_screen.dart';
import '../services/saved_images_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final savedPath = await SavedImagesService.saveToAppFolder(image.path);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: savedPath),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Galeri hatası: $e')),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çıkış yapıldı')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış yapılırken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final green = const Color(0xFF7CB68A);
    final darkGreen = const Color(0xFF4D7C57);
    final softBg = const Color(0xFFFFFBFC);

    return Scaffold(
      backgroundColor: softBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ana Sayfa',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: darkGreen,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: darkGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => _signOut(context),
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Merhaba, ${(user?.displayName?.split(' ').first )}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bugün ne analiz etmek istersin?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEAF6EA),
                          Color(0xFFD9F0D8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
  children: [
    // 📸 ARKA PLAN GÖRSEL
    Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/images/product.png',
          fit: BoxFit.cover,
        ),
      ),
    ),

    // 🌫️ GRADIENT
    Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.35),
              Colors.black.withValues(alpha: 0.1),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
    ),

    // ✨ TEXT
    Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
            ),
          ),
          const Spacer(),
          
        ],
      ),
    ),
  ],
),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          title: 'Kamera',
                          icon: Icons.camera_alt_rounded,
                          backgroundColor: green,
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CameraScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ActionCard(
                          title: 'Galeriden\nSeç',
                          icon: Icons.photo_library_rounded,
                          backgroundColor: const Color(0xFFE8F3E8),
                          textColor: darkGreen,
                          iconColor: darkGreen,
                          onTap: () => _pickImageFromGallery(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Son Analizler',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedImagesScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Tümünü Gör',
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _RecentAnalysisCard(
                    title: 'Çilekli Süt',
                    date: 'Analiz tarihi: 25.3.2026',
                    score: 'Yanıltıcılık skoru: 75',
                    chipText: 'ORTA',
                    chipColor: const Color(0xFFF3D8B2),
                  ),
                  const SizedBox(height: 14),
                  _RecentAnalysisCard(
                    title: 'Analiz Edilen Ürün',
                    date: 'Analiz tarihi: 25.3.2026',
                    score: 'Yanıltıcılık skoru: 61',
                    chipText: 'DÜŞÜK',
                    chipColor: const Color(0xFFDDF0DD),
                  ),
                ],
              ),
            ),
            _BottomHomeBar(
              onHomeTap: () {},
              onCenterTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraScreen()),
                );
              },
              onSavedTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SavedImagesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
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

class _RecentAnalysisCard extends StatelessWidget {
  final String title;
  final String date;
  final String score;
  final String chipText;
  final Color chipColor;

  const _RecentAnalysisCard({
    required this.title,
    required this.date,
    required this.score,
    required this.chipText,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_drink_rounded,
              size: 36,
              color: Color(0xFFE8578A),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        score,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        chipText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomHomeBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onCenterTap;
  final VoidCallback onSavedTap;

  const _BottomHomeBar({
    required this.onHomeTap,
    required this.onCenterTap,
    required this.onSavedTap,
  });

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF7CB68A);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onHomeTap,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_rounded, color: Color(0xFF7CB68A)),
                  SizedBox(height: 4),
                  Text(
                    'Ana Sayfa',
                    style: TextStyle(
                      color: Color(0xFF7CB68A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onCenterTap,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: green.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onSavedTap,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_rounded, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(
                    'Kayıtlarım',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}