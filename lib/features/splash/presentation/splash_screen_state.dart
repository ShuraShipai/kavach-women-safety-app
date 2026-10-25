part of 'splash_screen.dart';

class _SplashScreenState extends State<SplashScreen> {
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _advanceTimer = Timer(const Duration(seconds: 2), _continue);
  }

  void _continue() {
    if (mounted) widget.onContinue?.call();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widthByViewport =
                constraints.maxWidth *
                SplashLayoutTokens.logoViewportWidthFraction;
            final widthByHeight =
                constraints.maxHeight *
                SplashLayoutTokens.logoMaxViewportHeightFraction *
                SplashLayoutTokens.logoAspectRatio;
            final logoWidth = math.min(
              SplashLayoutTokens.logoMaxWidth,
              math.min(widthByViewport, widthByHeight),
            );

            return Center(
              child: GestureDetector(
                onTap: _continue,
                child: Image.asset(
                  'assets/brand/kavach_logo_transparent.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                  semanticLabel: 'Kavach · Safe Today. Stronger Tomorrow.',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
