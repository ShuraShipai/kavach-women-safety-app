part of 'message_analysis_progress_screen.dart';

class _MessageAnalysisProgressScreenState
    extends ConsumerState<MessageAnalysisProgressScreen> {
  Timer? _transition;

  @override
  void initState() {
    super.initState();
    _transition = Timer(const Duration(milliseconds: 900), () {
      if (mounted) context.go('/shield/message/result');
    });
  }

  @override
  void dispose() {
    _transition?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.buildProgress(context);
}
