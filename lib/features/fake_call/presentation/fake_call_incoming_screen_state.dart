part of 'fake_call_incoming_screen.dart';

class _FakeCallIncomingScreenState extends ConsumerState<FakeCallIncomingScreen>
    with WidgetsBindingObserver {
  bool _ringingEligible = false;
  bool _ringtoneStarting = false;
  bool _ringtoneFailed = false;
  bool _callActive = true;
  int _ringGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.details.delaySeconds == 0) {
      _ringingEligible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_startRingtone());
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _ringGeneration++;
      unawaited(ref.read(fakeCallRingtoneServiceProvider).stop());
    } else if (state == AppLifecycleState.resumed &&
        _ringingEligible &&
        _callActive) {
      unawaited(_startRingtone());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ringGeneration++;
    unawaited(ref.read(fakeCallRingtoneServiceProvider).stop());
    super.dispose();
  }

  Future<void> _startRingtone() async {
    if (!mounted || !_ringingEligible || !_callActive) return;
    if (_ringtoneStarting) return;
    final generation = ++_ringGeneration;
    final ringtone = ref.read(fakeCallRingtoneServiceProvider);
    _ringtoneStarting = true;
    try {
      await ringtone.start();
      _ringtoneStarting = false;
      if (!mounted || generation != _ringGeneration || !_callActive) {
        await ringtone.stop();
        return;
      }
      setState(() => _ringtoneFailed = false);
    } on Object {
      _ringtoneStarting = false;
      if (mounted && generation == _ringGeneration) {
        setState(() => _ringtoneFailed = true);
      }
    }
  }

  Future<void> _stopRingtone() async {
    _callActive = false;
    _ringingEligible = false;
    _ringGeneration++;
    try {
      await ref.read(fakeCallRingtoneServiceProvider).stop();
    } on Object {
      // Navigation remains available if audio playback fails.
    }
  }

  Future<void> _leaveFor(String location) async {
    await _stopRingtone();
    if (mounted) context.go(location, extra: widget.details);
  }

  Future<void> _openHelp() async {
    await _stopRingtone();
    if (mounted) context.go('/help');
  }

  @override
  Widget build(BuildContext context) {
    final countdown = fakeCallCountdownProvider(widget.details.delaySeconds);
    ref.listen<AsyncValue<int>>(countdown, (previous, next) {
      if (next.value == 0) {
        _ringingEligible = true;
        unawaited(_startRingtone());
      }
    });
    final timer = ref.watch(countdown);
    final seconds = timer.value ?? widget.details.delaySeconds;
    final waiting = seconds > 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leaveFor('/home'));
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: AppColors.charcoal,
        ),
        child: Scaffold(
          backgroundColor: AppColors.charcoal,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KAVACH · SIMULATED CALL',
                        style: TextStyle(
                          color: AppColors.surfaceWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      TextButton(
                        onPressed: _openHelp,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          backgroundColor: AppColors.brandCrimson,
                          foregroundColor: AppColors.surfaceWhite,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'SOS',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.coolGray,
                          backgroundImage: widget.details.photoPath == null
                              ? null
                              : FileImage(File(widget.details.photoPath!)),
                          child: widget.details.photoPath == null
                              ? Text(
                                  widget.details.callerName.characters.first
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandCrimson,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          widget.details.callerName,
                          style: const TextStyle(
                            color: AppColors.surfaceWhite,
                            fontSize: 30,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'mobile',
                          style: TextStyle(
                            color: AppColors.coolGray,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          waiting
                              ? 'Simulated call in $seconds seconds'
                              : 'Incoming call',
                          style: const TextStyle(
                            color: AppColors.coolGray,
                            fontSize: 15,
                          ),
                        ),
                        if (!waiting && _ringtoneFailed)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Ringtone unavailable. You can still answer.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.surfaceWhite),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (waiting)
                    OutlinedButton(
                      onPressed: () => _leaveFor('/home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.surfaceWhite,
                        side: const BorderSide(color: AppColors.coolGray),
                      ),
                      child: const Text('Cancel scheduled call'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _callAction(
                            icon: Icons.call_end,
                            label: 'Decline',
                            color: AppColors.charcoal,
                            onTap: () => _leaveFor('/fake-call/ended'),
                          ),
                          _callAction(
                            icon: Icons.call,
                            label: 'Answer',
                            color: AppColors.brandCrimson,
                            onTap: () => _leaveFor('/fake-call/active'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _callAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) => Column(
    children: [
      SizedBox(
        width: 68,
        height: 68,
        child: IconButton.filled(
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppColors.surfaceWhite,
          ),
          icon: Icon(icon, size: 28),
        ),
      ),
      TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: AppColors.surfaceWhite),
        child: Text(label),
      ),
    ],
  );
}
