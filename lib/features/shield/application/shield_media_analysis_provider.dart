import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/shield/domain/shield_media_analysis_result.dart';
import 'package:kavach/features/shield/domain/shield_media_analyzer.dart';

final shieldMediaAnalyzerProvider = Provider<ShieldMediaAnalyzer>(
  (ref) => throw StateError('Media analysis is not configured.'),
);

final shieldMediaAnalysisControllerProvider =
    NotifierProvider<ShieldMediaAnalysisController, ShieldMediaAnalysisState>(
      ShieldMediaAnalysisController.new,
    );

class ShieldMediaAnalysisState {
  const ShieldMediaAnalysisState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  final bool isLoading;
  final ShieldMediaAnalysisResult? result;
  final String? error;
}

class ShieldMediaAnalysisController extends Notifier<ShieldMediaAnalysisState> {
  @override
  ShieldMediaAnalysisState build() => const ShieldMediaAnalysisState();

  Future<void> analyze({
    required String path,
    required String fileName,
    required String kind,
  }) async {
    state = const ShieldMediaAnalysisState(isLoading: true);
    try {
      final result = await ref
          .read(shieldMediaAnalyzerProvider)
          .analyze(path: path, fileName: fileName, kind: kind);
      state = ShieldMediaAnalysisState(result: result);
    } on Object catch (error) {
      state = ShieldMediaAnalysisState(error: error.toString());
      rethrow;
    }
  }

  void clear() => state = const ShieldMediaAnalysisState();
}
