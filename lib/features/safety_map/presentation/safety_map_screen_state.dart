part of 'safety_map_screen.dart';

class _SafetyMapScreenState extends ConsumerState<SafetyMapScreen> {
  bool _concerns = true;
  bool _lighting = true;
  bool _stations = true;
  bool _hospitals = true;
  bool _locating = false;
  MapPoint? _userPoint;
  String? _locationError;
  String? _locationNotice;
  List<NearbyHelpPlace> _nearbyHelpPlaces = const [];
  bool _nearbyHelpLoading = false;
  String? _nearbyHelpError;
  final fm.MapController _mapController = fm.MapController();
  bool _mapReady = false;
  bool _tileLoadFailed = false;
  int _mapGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _locate();
    });
  }

  void _retryMap() {
    setState(() {
      _tileLoadFailed = false;
      _mapGeneration++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(safetyRecordsProvider);
    final filters = SafetyMapFilters(
      concerns: _concerns,
      lighting: _lighting,
      stations: _stations,
    );
    final visible =
        records.asData?.value
            .where(filters.includes)
            .where(_isVisibleAtCurrentLocation)
            .toList() ??
        const [];
    final nearbyVisible = _nearbyHelpPlaces.where((place) {
      return switch (place.kind) {
        NearbyHelpPlaceKind.policeStation => _stations,
        NearbyHelpPlaceKind.hospital => _hospitals,
      };
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.phaseCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Back to Home',
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.chevron_left, size: 28),
                  color: AppColors.brandCrimson,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 13),
              child: Text('Safety map', style: AppTypography.phaseHeaderTitle),
            ),
            SizedBox(
              height: 38,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip(
                      label: 'Reported concerns',
                      selected: _concerns,
                      onSelected: (value) => setState(() => _concerns = value),
                    ),
                    const SizedBox(width: 7),
                    _filterChip(
                      label: 'Poor lighting',
                      selected: _lighting,
                      onSelected: (value) => setState(() => _lighting = value),
                    ),
                    const SizedBox(width: 7),
                    _filterChip(
                      label: 'Police stations',
                      selected: _stations,
                      onSelected: (value) => setState(() => _stations = value),
                    ),
                    const SizedBox(width: 7),
                    _filterChip(
                      label: 'Hospitals',
                      selected: _hospitals,
                      onSelected: (value) => setState(() => _hospitals = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      fm.FlutterMap(
                        key: ValueKey(_mapGeneration),
                        mapController: _mapController,
                        options: fm.MapOptions(
                          initialCenter: const ll.LatLng(20.5937, 78.9629),
                          initialZoom: 4.2,
                          onMapReady: () {
                            _mapReady = true;
                            final point = _userPoint;
                            if (point != null) {
                              _mapController.move(
                                ll.LatLng(point.latitude, point.longitude),
                                15,
                              );
                            }
                          },
                        ),
                        children: [
                          fm.TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.kavach',
                            tileProvider: fm.NetworkTileProvider(
                              headers: {
                                'User-Agent':
                                    'Kavach/0.1.0 (com.example.kavach)',
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
                              for (final record in visible) _marker(record),
                              for (final place in nearbyVisible)
                                _nearbyHelpMarker(place),
                              if (_userPoint case final point?)
                                fm.Marker(
                                  point: ll.LatLng(
                                    point.latitude,
                                    point.longitude,
                                  ),
                                  width: 34,
                                  height: 34,
                                  child: const UserLocationDot(),
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
                      if (records.isLoading)
                        const Center(
                          child: SizedBox.square(
                            dimension: 36,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      if (_tileLoadFailed)
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 12,
                          child: MapStatusCard(
                            message:
                                'Map tiles could not load. Check your connection and retry.',
                            action: 'Retry',
                            onPressed: _retryMap,
                          ),
                        ),
                      if (_nearbyHelpLoading)
                        const Positioned(
                          left: 12,
                          top: 12,
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Finding nearby help…'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_nearbyHelpError != null)
                        Positioned(
                          left: 12,
                          right: 66,
                          top: _tileLoadFailed ? 76 : 12,
                          child: MapStatusCard(
                            message: _nearbyHelpError!,
                            action: 'Retry',
                            onPressed: _userPoint == null
                                ? _locate
                                : () => _loadNearbyHelp(_userPoint!),
                          ),
                        ),
                      if (records.hasError ||
                          (records.hasValue &&
                              visible.isEmpty &&
                              nearbyVisible.isEmpty &&
                              !_nearbyHelpLoading &&
                              _nearbyHelpError == null))
                        Positioned(
                          left: 12,
                          right: 12,
                          top: _tileLoadFailed ? 76 : 12,
                          child: MapStatusCard(
                            message: records.hasError
                                ? _dataErrorMessage(records.error)
                                : _userPoint == null
                                ? 'Use your location to find nearby police stations and hospitals. No sample pins are shown.'
                                : 'No police stations or hospitals are mapped within 5 km. OpenStreetMap coverage may be incomplete.',
                            action: records.hasError ? 'Retry' : null,
                            onPressed: records.hasError
                                ? () => ref.invalidate(safetyRecordsProvider)
                                : null,
                          ),
                        ),
                      if (_locationError != null)
                        Positioned(
                          left: 12,
                          right: 66,
                          bottom: 12,
                          child: MapStatusCard(
                            message: _locationError!,
                            action: 'Dismiss',
                            onPressed: () =>
                                setState(() => _locationError = null),
                          ),
                        ),
                      if (_locationNotice != null)
                        Positioned(
                          left: 12,
                          right: 66,
                          bottom: 12,
                          child: MapStatusCard(message: _locationNotice!),
                        ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: FloatingActionButton.small(
                            heroTag: 'my-location',
                            tooltip: 'Show my location',
                            onPressed: _locating ? null : _locate,
                            child: _locating
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 9, 16, 0),
              child: SafetyMapLegend(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                'Nearby search sends an approximate location to OpenStreetMap. Police and hospital data may be incomplete or outdated. Community reports are unverified; no report does not mean an area is safe.',
                style: AppTypography.phaseMin,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SizedBox(
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandCrimson,
                    foregroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  onPressed: () => context.push('/safety-map/report'),
                  child: const Text(
                    'Report a spot',
                    style: AppTypography.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const KavachBottomNavigation(selected: 'Map'),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) => FilterChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    onSelected: onSelected,
    labelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: selected ? AppColors.surfaceWhite : AppColors.charcoal,
    ),
    backgroundColor: AppColors.surfaceWhite,
    selectedColor: AppColors.brandCrimson,
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 2),
    visualDensity: VisualDensity.compact,
  );

  String _dataErrorMessage(Object? error) {
    if (error is SafetyMapDataException && error.code == 'permission-denied') {
      return 'Map data access is blocked by Firebase rules. The project owner must deploy the updated Firestore rules.';
    }
    return 'Map data could not be loaded. Check your connection and try again.';
  }

  fm.Marker _marker(SafetyRecord record) => fm.Marker(
    point: ll.LatLng(record.point.latitude, record.point.longitude),
    width: 42,
    height: 48,
    child: GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => SafetyRecordSheet(record: record),
      ),
      child: Icon(
        record.kind == SafetyRecordKind.helpPoint
            ? Icons.local_police
            : record.category == SafetyCategory.poorLighting
            ? Icons.warning_amber_rounded
            : Icons.report,
        color: record.kind == SafetyRecordKind.helpPoint
            ? const Color(0xFF242326)
            : record.category == SafetyCategory.poorLighting
            ? const Color(0xFF8D5D19)
            : AppColors.brandCrimson,
        size: 34,
      ),
    ),
  );

  fm.Marker _nearbyHelpMarker(NearbyHelpPlace place) => fm.Marker(
    point: ll.LatLng(place.point.latitude, place.point.longitude),
    width: 44,
    height: 48,
    child: GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => NearbyHelpPlaceSheet(place: place),
      ),
      child: Icon(
        place.kind == NearbyHelpPlaceKind.policeStation
            ? Icons.local_police
            : Icons.local_hospital,
        color: place.kind == NearbyHelpPlaceKind.policeStation
            ? AppColors.charcoal
            : AppColors.brandCrimson,
        size: 34,
      ),
    ),
  );

  bool _isVisibleAtCurrentLocation(SafetyRecord record) {
    if (record.kind != SafetyRecordKind.helpPoint) return true;
    final userPoint = _userPoint;
    if (userPoint == null) return false;
    return _distanceMeters(
          userPoint.latitude,
          userPoint.longitude,
          record.point.latitude,
          record.point.longitude,
        ) <=
        5000;
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) =>
      const ll.Distance().as(
        ll.LengthUnit.Meter,
        ll.LatLng(lat1, lon1),
        ll.LatLng(lat2, lon2),
      );

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locationError = null;
      _locationNotice = null;
    });
    try {
      final point = await ref
          .read(foregroundLocationServiceProvider)
          .currentLocation();
      if (!mounted) return;
      setState(() {
        _userPoint = point;
        _locationNotice = point.accuracyMeters == null
            ? null
            : '${point.isApproximate ? 'Approximate' : 'Precise'} location · about ${point.accuracyMeters!.round()} m accuracy';
      });
      if (_mapReady) {
        _mapController.move(ll.LatLng(point.latitude, point.longitude), 15);
      }
      unawaited(_loadNearbyHelp(point));
    } on LocationException catch (error) {
      if (!mounted) return;
      setState(
        () => _locationError = switch (error.reason) {
          LocationFailure.denied =>
            'Location access was denied. You can still browse the map or choose a place manually when reporting.',
          LocationFailure.permanentlyDenied =>
            'Location access is disabled for Kavach. Change it in your device settings to use your location.',
          LocationFailure.unavailable =>
            'Your location is unavailable. Check that location services are on and try again.',
        },
      );
    } on Object {
      if (mounted) {
        setState(
          () => _locationError =
              'Could not determine your location. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _loadNearbyHelp(MapPoint center) async {
    setState(() {
      _nearbyHelpLoading = true;
      _nearbyHelpError = null;
    });
    try {
      final places = await ref
          .read(nearbyHelpPlaceSourceProvider)
          .loadNearby(center);
      if (mounted) {
        setState(() {
          _nearbyHelpPlaces = places
              .where(
                (place) =>
                    _distanceMeters(
                      center.latitude,
                      center.longitude,
                      place.point.latitude,
                      place.point.longitude,
                    ) <=
                    5000,
              )
              .toList();
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _nearbyHelpPlaces = const [];
          _nearbyHelpError =
              'Nearby help places could not be loaded. Check your connection and retry.';
        });
      }
    } finally {
      if (mounted) setState(() => _nearbyHelpLoading = false);
    }
  }
}
