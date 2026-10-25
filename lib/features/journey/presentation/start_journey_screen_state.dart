part of 'start_journey_screen.dart';

class _StartJourneyScreenState extends ConsumerState<StartJourneyScreen> {
  final _destinationController = TextEditingController();
  int _duration = 30;
  bool _guardian = false;
  bool _searching = false;
  String? _searchError;

  void _openMapAtCurrentLocation() {
    context.push(
      '/journey/monitoring',
      extra: JourneyDraft(
        destination: _destinationController.text.trim(),
        durationMinutes: _duration,
        guardianEnabled: _guardian,
      ),
    );
  }

  Future<void> _startJourney() async {
    if (_searching) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final location = await ref.read(searchJourneyDestinationProvider)(
        _destinationController.text,
      );
      if (!mounted) return;
      if (location == null) {
        setState(() {
          _searchError =
              'We could not find that place. Try adding its city or a nearby landmark.';
        });
        return;
      }
      context.push(
        '/journey/monitoring',
        extra: JourneyDraft(
          destination: _destinationController.text.trim(),
          destinationLocation: location,
          durationMinutes: _duration,
          guardianEnabled: _guardian,
        ),
      );
    } on Object {
      if (!mounted) return;
      setState(() {
        _searchError =
            'Destination search is unavailable. Check your connection and retry.';
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.phaseCream,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                IconButton(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Plan your journey',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose a destination and expected arrival. Guardian is optional.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 18),
                _label('Destination'),
                const SizedBox(height: 6),
                TextField(
                  controller: _destinationController,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration('Search for a place'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Destination search is sent to OpenStreetMap to find its map location.',
                  style: TextStyle(fontSize: 11, height: 1.3),
                ),
                if (_searchError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _searchError!,
                    style: const TextStyle(
                      color: AppColors.brandCrimson,
                      fontSize: 12,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _searching ? null : _openMapAtCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Open map at my location instead'),
                  ),
                ],
                const SizedBox(height: 14),
                _label('Expected journey time'),
                const SizedBox(height: 8),
                Row(
                  children: [15, 30, 45].map((minutes) {
                    final selected = _duration == minutes;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$minutes min'),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _duration = minutes),
                          selectedColor: AppColors.brandCrimson,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                          showCheckmark: false,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Safe Journey · Optional',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Switch.adaptive(
                            value: _guardian,
                            activeTrackColor: AppColors.brandCrimson,
                            onChanged: (value) =>
                                setState(() => _guardian = value),
                          ),
                        ],
                      ),
                      const Text(
                        'May suggest arrival or a delay where supported. Location updates can pause because of signal, permissions, battery, or background limits.',
                        style: TextStyle(fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Battery Handoff'),
                      content: const Text(
                        'Battery handoff is not configured on this device. Your journey will not be transferred to another device.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.battery_alert_outlined,
                          color: AppColors.brandCrimson,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Battery Handoff',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Optional for this journey · best effort',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Set up ›',
                          style: TextStyle(
                            color: AppColors.brandCrimson,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandCrimson,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed:
                    _destinationController.text.trim().isEmpty || _searching
                    ? null
                    : _startJourney,
                child: _searching
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Start Journey',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
          const KavachBottomNavigation(selected: 'Map'),
        ],
      ),
    ),
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide.none,
    ),
  );
}
