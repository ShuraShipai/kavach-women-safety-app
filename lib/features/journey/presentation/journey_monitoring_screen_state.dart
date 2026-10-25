part of 'journey_monitoring_screen.dart';

class _JourneyMonitoringScreenState
    extends ConsumerState<JourneyMonitoringScreen> {
  MapPoint? _location;
  bool _locating = false;
  String? _locationMessage;
  final fm.MapController _mapController = fm.MapController();
  bool _mapReady = false;
  bool _tileLoadFailed = false;
  int _mapGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _requestLocation();
    });
  }

  void _retryMap() {
    setState(() {
      _tileLoadFailed = false;
      _mapGeneration++;
    });
  }

  Future<void> _requestLocation() async {
    setState(() {
      _locating = true;
      _locationMessage = null;
    });
    try {
      final point = await ref
          .read(foregroundLocationProvider)
          .currentLocation();
      if (!mounted) return;
      setState(() {
        _location = point;
        _locationMessage = point.accuracyMeters == null
            ? null
            : '${point.isApproximate ? 'Approximate' : 'Precise'} location · about ${point.accuracyMeters!.round()} m accuracy';
      });
      if (_mapReady) {
        _mapController.move(ll.LatLng(point.latitude, point.longitude), 15);
      }
    } on LocationException catch (error) {
      if (!mounted) return;
      setState(() {
        _locationMessage = switch (error.reason) {
          LocationFailure.denied =>
            'Location permission was denied. You can continue without location.',
          LocationFailure.permanentlyDenied =>
            'Location is blocked in settings. You can continue without location.',
          LocationFailure.unavailable =>
            'Location is unavailable right now. You can continue without location.',
        };
      });
    } on Object {
      if (!mounted) return;
      setState(
        () => _locationMessage =
            'Could not get your location. You can continue without it.',
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationLocation = widget.journey.destinationLocation;
    final destination = destinationLocation == null
        ? null
        : ll.LatLng(
            destinationLocation.latitude,
            destinationLocation.longitude,
          );
    final center = _location == null
        ? destination ?? const ll.LatLng(20.5937, 78.9629)
        : ll.LatLng(_location!.latitude, _location!.longitude);
    return Scaffold(
      backgroundColor: AppColors.phaseCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Automatic Monitoring',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'SAFE JOURNEY  ·  PREVIEW',
                style: TextStyle(
                  color: AppColors.phaseSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      context,
                      label: 'Call 112',
                      onTap: _call112,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      context,
                      label: 'SOS',
                      outlined: true,
                      onTap: _sosInfo,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  fm.FlutterMap(
                    key: ValueKey(_mapGeneration),
                    mapController: _mapController,
                    options: fm.MapOptions(
                      initialCenter: center,
                      initialZoom: 14,
                      onMapReady: () => _mapReady = true,
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.kavach',
                        tileProvider: fm.NetworkTileProvider(
                          headers: {
                            'User-Agent': 'Kavach/0.1.0 (com.example.kavach)',
                          },
                        ),
                        errorTileCallback: (_, _, _) {
                          if (mounted && !_tileLoadFailed) {
                            setState(() => _tileLoadFailed = true);
                          }
                        },
                      ),
                      fm.MarkerLayer(
                        markers: [
                          if (destination != null)
                            fm.Marker(
                              point: destination,
                              width: 46,
                              height: 48,
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.brandCrimson,
                                size: 42,
                              ),
                            ),
                          if (_location != null)
                            fm.Marker(
                              point: ll.LatLng(
                                _location!.latitude,
                                _location!.longitude,
                              ),
                              width: 32,
                              height: 32,
                              child: const JourneyLocationDot(),
                            ),
                        ],
                      ),
                      const fm.RichAttributionWidget(
                        alignment: fm.AttributionAlignment.bottomLeft,
                        attributions: [
                          fm.TextSourceAttribution(
                            '© OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!_tileLoadFailed)
                    Positioned(
                      right: 14,
                      bottom: 18,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (destination != null) ...[
                            FloatingActionButton.small(
                              heroTag: 'journey_destination',
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.brandCrimson,
                              tooltip: 'Show destination',
                              onPressed: () =>
                                  _mapController.move(destination, 14),
                              child: const Icon(Icons.place_outlined),
                            ),
                            const SizedBox(height: 8),
                          ],
                          FloatingActionButton.small(
                            heroTag: 'journey_location',
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.brandCrimson,
                            tooltip: 'Show my location',
                            onPressed: _locating ? null : _requestLocation,
                            child: _locating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                          ),
                        ],
                      ),
                    ),
                  if (_locationMessage != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 16,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(_locationMessage!),
                        ),
                      ),
                    ),
                  if (_tileLoadFailed)
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 16,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Map tiles could not load. Check your connection and retry.',
                                ),
                              ),
                              TextButton(
                                onPressed: _retryMap,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.phaseCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${widget.journey.durationMinutes} min · ${destinationLocation?.label ?? widget.journey.destination}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (destination == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Destination pin unavailable. The map is showing your current location when permitted.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Journey active in this app · no background location is collected.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.journey.guardianEnabled
                        ? 'Arrival detection is unavailable in this build. Location updates may pause due to signal, permission, battery, or background limits.'
                        : 'Location updates are off. Safe Journey was not enabled.',
                    style: const TextStyle(fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _confirmArrival(context),
                    child: const Text(
                      'Confirm arrival if detection is unavailable',
                    ),
                  ),
                ],
              ),
            ),
            const KavachBottomNavigation(selected: 'Map'),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool outlined = false,
  }) => SizedBox(
    height: 48,
    child: outlined
        ? OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandCrimson,
              side: const BorderSide(color: AppColors.brandCrimson),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          )
        : FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandCrimson,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
  );

  Future<void> _call112() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Open emergency call options?'),
        content: const Text(
          'Your phone app will handle the call to 112. Kavach cannot confirm that it connects.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Open phone app'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    var opened = false;
    try {
      opened = await ref.read(openEmergencyDialerProvider).call();
    } on Object {
      opened = false;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? 'Phone app opened. Complete the call there.'
                : 'Could not open phone app. No call was placed.',
          ),
        ),
      );
    }
  }

  Future<void> _sosInfo() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('SOS is not connected'),
      content: const Text(
        'No alert was sent. Emergency messaging is not configured in this build.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _confirmArrival(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm arrival?'),
        content: const Text(
          'This journey will end on this device. No contact notification is sent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep journey open'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/home');
            },
            child: const Text('End journey'),
          ),
        ],
      ),
    );
  }
}
