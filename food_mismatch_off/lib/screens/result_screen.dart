import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../services/saved_images_service.dart';

// Ana yeşil ton — görseldeki soft sage green
const _kGreen = Color(0xFF7EAF8D);

class ResultScreen extends StatefulWidget {
  final String? imagePath;

  const ResultScreen({super.key, this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final AnalysisResult result;

  @override
  void initState() {
    super.initState();
    result = AnalysisResult.mock();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.imagePath != null) {
        await SavedImagesService.updateAnalysisByPath(
          widget.imagePath!,
          result,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EC),
      appBar: AppBar(
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analiz Sonucu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFFE8578A),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero bölümü: AppBar ile aynı yeşil, görsel sağda taşıyor ──
            Container(
              width: double.infinity,
              color: _kGreen,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sol: ürün adı + tarih
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 160, 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.productName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Analiz tarihi:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _formattedDate(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sağ: ürün görseli (biraz taşıyor — görseldeki gibi)
                  Positioned(
                    right: 8,
                    top: -8,
                    bottom: 8,
                    child: SizedBox(
                      width: 150,
                      child: widget.imagePath != null
                          ? Image.file(
                              File(widget.imagePath!),
                              fit: BoxFit.contain,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Yuvarlak köşeli geçiş (üste doğru hafifçe kaplıyor) ──
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0EC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Yanıltıcılık Skoru
                  _buildScoreCard(result.misleadingScore),
                  const SizedBox(height: 14),

                  // Yan yana kartlar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildCard(
                          title: 'Ambalajda Tespit\nEdilen Görseller',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                children:
                                    _visualEmojis(result.detectedVisuals),
                              ),
                              const SizedBox(height: 10),
                              ...result.detectedVisuals
                                  .map((v) => _checkRow(v, _kGreen)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCard(
                          title: 'Ürün İçeriği',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: result.actualIngredients
                                .map((i) => _checkRow(i, _kGreen))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  _buildRiskCard(result.healthRisk),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    final scoreColor = _scoreColor(score);
    final label = _scoreLabel(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yanıltıcılık Skoru',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'YANITLTICI',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Yanıltıcılık skoru: $score',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 86,
            height: 86,
            child: CustomPaint(
              painter: _CircleScorePainter(score: score, color: scoreColor),
              child: Center(
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _checkRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 16, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _visualEmojis(List<String> visuals) {
    final emojis = ['🥛', '🍓', '🍯', '🌿', '🫐', '🍋'];
    return List.generate(
      visuals.length.clamp(0, emojis.length),
      (i) => Text(emojis[i], style: const TextStyle(fontSize: 22)),
    );
  }

  Widget _buildRiskCard(String risk) {
    final color = _riskColor(risk);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(_riskIcon(risk), color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sağlık Riski: ${risk.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _riskDescription(risk),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day}.${now.month}.${now.year}';
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return const Color(0xFF5DA96B);
      case 'orta':
        return const Color(0xFFE2A53B);
      case 'yüksek':
        return const Color(0xFFD95C5C);
      default:
        return Colors.grey;
    }
  }

  IconData _riskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return Icons.check_circle_rounded;
      case 'orta':
        return Icons.warning_amber_rounded;
      case 'yüksek':
        return Icons.error_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _scoreColor(int score) {
    if (score >= 70) return const Color(0xFFE2A53B);
    if (score >= 40) return const Color(0xFFE2835D);
    return const Color(0xFF5DA96B);
  }

  String _scoreLabel(int score) {
    if (score >= 70) return 'Orta';
    if (score >= 40) return 'Düşük';
    return 'İyi';
  }

  String _riskDescription(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return 'İçerik açısından dikkat çekici büyük bir risk görünmüyor.';
      case 'orta':
        return 'Bazı içerikler dikkat gerektirebilir. Etiket dikkatlice incelenmeli.';
      case 'yüksek':
        return 'Dikkat edilmesi gereken riskli içerikler veya ciddi uyumsuzluk olabilir.';
      default:
        return 'Risk seviyesi değerlendirilemedi.';
    }
  }
}

// ── Dairesel skor çizici ──
class _CircleScorePainter extends CustomPainter {
  final int score;
  final Color color;

  _CircleScorePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleScorePainter old) =>
      old.score != score || old.color != color;
}