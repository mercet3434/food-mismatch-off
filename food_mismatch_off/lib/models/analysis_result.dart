class AnalysisResult {
  final String productName;
  final int misleadingScore;
  final List<String> detectedVisuals;
  final List<String> actualIngredients;
  final String healthRisk;

  AnalysisResult({
    required this.productName,
    required this.misleadingScore,
    required this.detectedVisuals,
    required this.actualIngredients,
    required this.healthRisk,
  });

  factory AnalysisResult.mock() {
    return AnalysisResult(
      productName: 'Çilekli Süt',
      misleadingScore: 75,
      detectedVisuals: ['çilek', 'süt', 'bal'],
      actualIngredients: ['su', 'şeker', 'çilek aroması', 'E211', 'E110'],
      healthRisk: 'orta',
    );
  }
}