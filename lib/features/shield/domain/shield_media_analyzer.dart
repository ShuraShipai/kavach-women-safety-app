import 'package:kavach/features/shield/domain/shield_media_analysis_result.dart';

abstract interface class ShieldMediaAnalyzer {
  Future<ShieldMediaAnalysisResult> analyze({
    required String path,
    required String fileName,
    required String kind,
  });
}
