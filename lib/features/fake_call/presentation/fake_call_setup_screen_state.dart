part of 'fake_call_setup_screen.dart';

class _FakeCallSetupScreenState extends ConsumerState<FakeCallSetupScreen> {
  late FakeCallDetails _details;
  bool _customTimingSelected = false;

  @override
  void initState() {
    super.initState();
    _details = widget.details.copyWith(
      callerName: widget.caller ?? widget.details.callerName,
      delaySeconds: widget.delaySeconds ?? widget.details.delaySeconds,
    );
    _customTimingSelected = !const [0, 5, 60].contains(_details.delaySeconds);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.warmCream,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back to Home',
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/home'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Fake Call',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const Text(
                  'Customize Fake Call',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Optional caller details. A call can start immediately.',
                ),
                const SizedBox(height: 22),
                _detailRow(
                  icon: Icons.person_outline,
                  label: 'Caller name',
                  value: _details.callerName,
                  action: 'Edit',
                  onTap: _editName,
                ),
                const SizedBox(height: 12),
                _detailRow(
                  icon: Icons.photo_outlined,
                  label: 'Caller photo',
                  value: _details.photoPath == null
                      ? 'Optional · choose from Photos'
                      : 'Photo selected',
                  action: _details.photoPath == null ? 'Choose' : 'Change',
                  onTap: _choosePhoto,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Call timing',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _timingChip('Now', 0),
                    _timingChip('5 sec', 5),
                    _timingChip('1 min', 60),
                    ChoiceChip(
                      label: const Text('Choose time'),
                      selected: _customTimingSelected,
                      onSelected: (_) => _chooseTime(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'This is a simulated call. It won’t connect to anyone or place a real call.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () =>
                      context.push('/fake-call/incoming', extra: _details),
                  child: Text(
                    _details.delaySeconds == 0
                        ? 'Start call now'
                        : 'Start simulated call',
                  ),
                ),
              ],
            ),
          ),
          const KavachBottomNavigation(selected: 'Home'),
        ],
      ),
    ),
  );

  Widget _timingChip(String label, int seconds) => ChoiceChip(
    label: Text(label),
    selected: !_customTimingSelected && _details.delaySeconds == seconds,
    onSelected: (_) => setState(() {
      _customTimingSelected = false;
      _details = _details.copyWith(delaySeconds: seconds);
    }),
  );

  Future<void> _chooseTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(Duration(seconds: _details.delaySeconds)),
      ),
    );
    if (selected == null || !mounted) return;
    final now = DateTime.now();
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      selected.hour,
      selected.minute,
    );
    if (!target.isAfter(now)) target = target.add(const Duration(days: 1));
    final delaySeconds = target.difference(now).inSeconds;
    setState(() {
      _customTimingSelected = true;
      _details = _details.copyWith(delaySeconds: delaySeconds);
    });
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required String action,
    required VoidCallback onTap,
  }) => Card(
    color: AppColors.surfaceWhite,
    child: ListTile(
      leading: Icon(icon, color: AppColors.brandCrimson),
      title: Text(label),
      subtitle: Text(value),
      trailing: Text(
        action,
        style: const TextStyle(color: AppColors.brandCrimson),
      ),
      onTap: onTap,
    ),
  );

  Future<void> _editName() async {
    var enteredName = _details.callerName;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Caller name'),
        content: TextFormField(
          initialValue: enteredName,
          autofocus: true,
          maxLength: 32,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => enteredName = value,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, enteredName.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || !mounted) return;
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a caller name.')));
      return;
    }
    setState(() => _details = _details.copyWith(callerName: name));
  }

  Future<void> _choosePhoto() async {
    try {
      final path = await ref.read(fakeCallPhotoPickerProvider).pickPhotoPath();
      if (path == null || !mounted) return;
      setState(() => _details = _details.copyWith(photoPath: path));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select a photo. Try again.')),
      );
    }
  }
}
