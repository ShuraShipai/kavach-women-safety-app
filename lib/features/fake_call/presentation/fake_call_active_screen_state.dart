part of 'fake_call_active_screen.dart';

class _FakeCallActiveScreenState extends ConsumerState<FakeCallActiveScreen>
    with WidgetsBindingObserver {
  static const _dialogue = <({String speaker, String line})>[
    (speaker: 'Caller', line: 'Hey, are you near the station entrance?'),
    (speaker: 'You', line: 'Yes, I’m just stepping inside now.'),
    (speaker: 'Caller', line: 'Good. Did you find the entrance okay?'),
    (speaker: 'You', line: 'Yes, my friend is waiting near the front desk.'),
    (
      speaker: 'Caller',
      line: 'Do you want me to stay on the phone for a little while?',
    ),
    (speaker: 'You', line: 'That would be great. Just for a little while.'),
    (speaker: 'Caller', line: 'Of course. Let me know once you’re settled.'),
    (speaker: 'You', line: 'I will. I’ll call you again in a few minutes.'),
  ];

  late final FakeCallVoiceService _voice;
  bool _voiceMuted = false;
  bool _quietSpeaker = false;
  bool _voiceFailed = false;
  String _voiceStatus = 'Starting caller voice…';
  int _speechGeneration = 0;

  @override
  void initState() {
    super.initState();
    _voice = ref.read(fakeCallVoiceServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakConversation();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _speechGeneration++;
      unawaited(_voice.stop());
      if (mounted && !_voiceMuted) {
        setState(() => _voiceStatus = 'Caller voice paused.');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speechGeneration++;
    unawaited(_voice.stop());
    super.dispose();
  }

  bool _canContinue(int generation) =>
      mounted && generation == _speechGeneration && !_voiceMuted;

  Future<void> _speakConversation() async {
    if (!mounted || _voiceMuted) return;
    final generation = ++_speechGeneration;
    setState(() {
      _voiceFailed = false;
      _voiceStatus = 'Speaking as ${widget.details.callerName}…';
    });
    try {
      var callerTurns = 0;
      for (final turn in _dialogue) {
        if (turn.speaker != 'Caller') continue;
        if (!_canContinue(generation)) return;
        setState(
          () => _voiceStatus = '${widget.details.callerName} is speaking…',
        );
        await _voice.speak(turn.line);
        if (!_canContinue(generation)) return;
        callerTurns++;
        if (callerTurns < 4) {
          await Future<void>.delayed(const Duration(milliseconds: 1900));
        }
      }
      setState(() => _voiceStatus = 'Caller paused · Replay voice');
    } on Object {
      if (!_canContinue(generation)) return;
      setState(() {
        _voiceFailed = true;
        _voiceStatus =
            'Voice unavailable. Check that an English system voice is installed.';
      });
    }
  }

  Future<void> _toggleMute() async {
    if (_voiceMuted) {
      setState(() {
        _voiceMuted = false;
        _voiceStatus = 'Replaying the caller voice…';
      });
      await _speakConversation();
      return;
    }
    _speechGeneration++;
    setState(() {
      _voiceMuted = true;
      _voiceStatus = 'Voice muted';
    });
    try {
      await _voice.stop();
    } on Object {
      if (mounted) setState(() => _voiceFailed = true);
    }
  }

  Future<void> _toggleSpeakerVolume() async {
    final quiet = !_quietSpeaker;
    try {
      await _voice.setVolume(quiet ? 0.35 : 1.0);
      if (!mounted) return;
      setState(() {
        _quietSpeaker = quiet;
        _voiceStatus = quiet
            ? 'Caller volume lowered'
            : 'Caller volume restored';
      });
    } on Object {
      if (mounted) {
        setState(() {
          _voiceFailed = true;
          _voiceStatus = 'Could not change caller volume.';
        });
      }
    }
  }

  Future<void> _endCall() async {
    _speechGeneration++;
    try {
      await _voice.stop();
    } on Object {
      // The end-call action stays available if TTS is unavailable.
    }
    if (mounted) context.go('/fake-call/ended', extra: widget.details);
  }

  Future<void> _openHelp() async {
    _speechGeneration++;
    await _voice.stop();
    if (mounted) context.push('/help');
  }

  Future<void> _showKeypad(BuildContext context) async {
    var digits = '';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.charcoal,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.surfaceWhite,
                    ),
                  ),
                ),
                Text(
                  digits.isEmpty ? 'Simulated keypad' : digits,
                  style: const TextStyle(
                    color: AppColors.surfaceWhite,
                    fontSize: 24,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.7,
                  children: [
                    for (final key in const [
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                      '*',
                      '0',
                      '#',
                    ])
                      FilledButton.tonal(
                        onPressed: () => setSheetState(() => digits += key),
                        child: Text(key, style: const TextStyle(fontSize: 20)),
                      ),
                  ],
                ),
                TextButton.icon(
                  onPressed: digits.isEmpty
                      ? null
                      : () => setSheetState(
                          () => digits = digits.substring(0, digits.length - 1),
                        ),
                  icon: const Icon(Icons.backspace_outlined),
                  label: const Text('Delete last digit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.surfaceWhite,
                  ),
                ),
                const Text(
                  'Digits are shown for the simulation only.',
                  style: TextStyle(color: AppColors.coolGray, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = ref.watch(fakeCallElapsedProvider).value ?? 0;
    final time =
        '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_endCall());
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: AppColors.charcoal,
        ),
        child: Scaffold(
          backgroundColor: AppColors.charcoal,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'SIMULATED CALL',
                          style: TextStyle(
                            color: AppColors.surfaceWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.surfaceWhite,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _openHelp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.surfaceWhite,
                          side: const BorderSide(color: AppColors.surfaceWhite),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text('SOS'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 41,
                    backgroundColor: AppColors.coolGray,
                    backgroundImage: widget.details.photoPath == null
                        ? null
                        : FileImage(File(widget.details.photoPath!)),
                    child: widget.details.photoPath == null
                        ? Text(
                            widget.details.callerName.characters.first
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              color: AppColors.brandCrimson,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.details.callerName,
                    style: const TextStyle(
                      color: AppColors.surfaceWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Call in progress · simulated only',
                    style: TextStyle(color: AppColors.coolGray, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    color: AppColors.charcoal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: AppColors.surfaceWhite.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.details.callerName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppColors.coolGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          for (var index = 0; index < _dialogue.length; index++)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '“${_dialogue[index].speaker == 'Caller' ? widget.details.callerName : 'You'}: ${_dialogue[index].line}”',
                                style: TextStyle(
                                  color: _dialogue[index].speaker == 'Caller'
                                      ? AppColors.surfaceWhite
                                      : AppColors.coolGray,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          const SizedBox(height: 7),
                          Text(
                            _voiceStatus,
                            style: TextStyle(
                              color: _voiceFailed
                                  ? AppColors.surfaceWhite
                                  : AppColors.coolGray,
                              fontSize: 11,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _voiceMuted
                                  ? null
                                  : _speakConversation,
                              icon: const Icon(Icons.replay, size: 17),
                              label: const Text('Replay voice'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.surfaceWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _voiceMuteControl(),
                      _keypadControl(context),
                      _speakerControl(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandCrimson,
                        foregroundColor: AppColors.surfaceWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _endCall,
                      icon: const Icon(Icons.call_end),
                      label: const Text('End call'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('/vault/recordings/capture'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.surfaceWhite,
                        side: BorderSide(
                          color: AppColors.surfaceWhite.withValues(alpha: 0.65),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Safety Mode'),
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

  Widget _voiceMuteControl() => _callControl(
    icon: _voiceMuted ? Icons.volume_off_outlined : Icons.mic_off_outlined,
    label: _voiceMuted ? 'Unmute' : 'Mute',
    onPressed: _toggleMute,
  );

  Widget _keypadControl(BuildContext context) => _callControl(
    icon: Icons.dialpad_outlined,
    label: 'Keypad',
    onPressed: () => _showKeypad(context),
  );

  Widget _speakerControl() => _callControl(
    icon: _quietSpeaker ? Icons.volume_down_outlined : Icons.volume_up_outlined,
    label: _quietSpeaker ? 'Louder' : 'Speaker',
    onPressed: _toggleSpeakerVolume,
  );

  Widget _callControl({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 48,
        height: 48,
        child: IconButton.filledTonal(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF343338),
            foregroundColor: AppColors.surfaceWhite,
          ),
          icon: Icon(icon),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.surfaceWhite),
      ),
    ],
  );
}
