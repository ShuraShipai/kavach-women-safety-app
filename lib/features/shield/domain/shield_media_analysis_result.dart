class ShieldMediaAnalysisResult {
  const ShieldMediaAnalysisResult({
    required this.kind,
    required this.isManipulated,
    required this.summary,
    this.confidencePercent,
    this.details,
  });

  final String kind;
  final bool? isManipulated;
  final int? confidencePercent;
  final String summary;
  final String? details;
}
