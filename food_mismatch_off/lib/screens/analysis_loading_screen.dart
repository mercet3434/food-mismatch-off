import 'dart:async';
import 'package:flutter/material.dart';

import 'result_screen.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final String imagePath;

  const AnalysisLoadingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> {
  int currentStep = 0;

  final steps = const [
    'Ön yüz görselleri analiz ediliyor...',
    'İçindekiler bölümü OCR ile okunuyor...',
    'Katkı maddeleri taranıyor...',
    'Yanıltıcılık skoru hesaplanıyor...',
  ];

  @override
  void initState() {
    super.initState();
    _runFakeAnalysis();
  }

  Future<void> _runFakeAnalysis() async {
    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;

      setState(() {
        currentStep = i;
      });
    }

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          imagePath: widget.imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryLilac = Color(0xFF8E73D8);
    const darkLilac = Color(0xFF2B2146);
    const mediumLilac = Color(0xFFD7B6FF);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF9FB),
              Color(0xFFF4EDFF),
              Color(0xFFFFEEF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        mediumLilac,
                        primaryLilac,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryLilac.withValues(alpha: 0.25),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 34),

                const Text(
                  'Analiz yapılıyor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkLilac,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  steps[currentStep],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: darkLilac.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 38),

                SizedBox(
                  width: 74,
                  height: 74,
                  child: CircularProgressIndicator(
                    color: primaryLilac,
                    backgroundColor: primaryLilac.withValues(alpha: 0.14),
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                  ),
                ),

                const SizedBox(height: 34),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: primaryLilac.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Text(
                    'Bu işlem birkaç saniye sürebilir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkLilac,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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