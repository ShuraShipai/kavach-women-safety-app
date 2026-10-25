part of 'report_spot_screen.dart';

class _ReportSpotScreenState extends ConsumerState<ReportSpotScreen> {
  final _noteController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  SafetyCategory _category = SafetyCategory.unsafe;
  SafetyTime _time = SafetyTime.night;
  MapPoint? _point;
  bool _submitting = false;
  String? _error;
  final fm.MapController _reportMapController = fm.MapController();
  bool _mapReady = false;
  bool _tileLoadFailed = false;
  int _mapGeneration = 0;

  @override
  void dispose() {
    _noteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.43;
    final center = _point == null
        ? const ll.LatLng(20.5937, 78.9629)
        : ll.LatLng(_point!.latitude, _point!.longitude);
    return Scaffold(
      backgroundColor: AppColors.coolGray,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: sheetHeight,
            child: fm.FlutterMap(
              key: ValueKey(_mapGeneration),
              mapController: _reportMapController,
              options: fm.MapOptions(
                initialCenter: center,
                initialZoom: _point == null ? 4.2 : 14,
                onMapReady: () => _mapReady = true,
                onTap: (_, position) => _selectPoint(position),
                onLongPress: (_, position) => _selectPoint(position),
              ),
              children: [
                fm.TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                if (_point != null)
                  fm.MarkerLayer(
                    markers: [
                      fm.Marker(
                        point: ll.LatLng(_point!.latitude, _point!.longitude),
                        width: 44,
                        height: 48,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.brandCrimson,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                const fm.RichAttributionWidget(
                  alignment: fm.AttributionAlignment.bottomLeft,
                  attributions: [
                    fm.TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
          if (_tileLoadFailed)
            Positioned(
              left: 16,
              right: 16,
              top: 18,
              child: MapStatusCard(
                message:
                    'Map tiles could not load. Check your connection. You can still tap the map or enter coordinates.',
                action: 'Retry',
                onPressed: _retryMap,
              ),
            ),
          if (_point == null)
            Positioned(
              left: 16,
              bottom: sheetHeight + 18,
              child: const MapStatusCard(
                message: 'Tap the map to place your report pin.',
              ),
            ),
          Positioned(
            right: 16,
            bottom: sheetHeight + 12,
            child: FloatingActionButton.small(
              heroTag: 'report-current-location',
              tooltip: 'Use my location',
              onPressed: _chooseMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: sheetHeight,
            child: _reportSheet(),
          ),
        ],
      ),
      bottomNavigationBar: const KavachBottomNavigation(selected: 'Map'),
    );
  }

  Widget _reportSheet() => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      boxShadow: [
        BoxShadow(
          color: Color(0x1A242326),
          blurRadius: 14,
          offset: Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.coolGray,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                SizedBox(
                  width: 86,
                  child: TextButton(
                    onPressed: _submitting ? null : () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Report a Spot',
                    textAlign: TextAlign.center,
                    style: AppTypography.controlStrong,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: TextButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Post'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.coolGray),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _choiceRow(
                  label: 'Category',
                  value: _category == SafetyCategory.unsafe
                      ? 'Unsafe'
                      : 'Poor lighting',
                  onTap: _chooseCategory,
                ),
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.coolGray,
                ),
                _choiceRow(
                  label: 'Time of day',
                  value: _capitalize(_time.name),
                  onTap: _chooseTime,
                ),
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.coolGray,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Note', style: AppTypography.caption),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          maxLines: 1,
                          maxLength: ReportValidation.maxNoteLength,
                          style: AppTypography.caption,
                          decoration: const InputDecoration(
                            hintText: 'What happened?',
                            counterText: '',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 5),
                  child: Text(
                    'Avoid personal details. Reports need review before appearing on the map.',
                    style: AppTypography.phaseMin,
                  ),
                ),
                if (_tileLoadFailed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latitudeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              isDense: true,
                            ),
                            onChanged: (_) => _updateManualPoint(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _longitudeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              isDense: true,
                            ),
                            onChanged: (_) => _updateManualPoint(),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_point != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                    child: Text(
                      'Pin: ${_point!.latitude.toStringAsFixed(5)}, ${_point!.longitude.toStringAsFixed(5)}${_point!.accuracyMeters == null ? '' : ' · ${_point!.isApproximate ? 'Approximate' : 'Precise'} ±${_point!.accuracyMeters!.round()} m'}',
                      style: AppTypography.phaseMin,
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _choiceRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.caption)),
            Text(value, style: AppTypography.caption),
            const SizedBox(width: 5),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.phaseSecondary,
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _chooseCategory() async {
    final selected = await showModalBottomSheet<SafetyCategory>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Unsafe'),
              onTap: () => Navigator.pop(context, SafetyCategory.unsafe),
            ),
            ListTile(
              title: const Text('Poor lighting'),
              onTap: () => Navigator.pop(context, SafetyCategory.poorLighting),
            ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _category = selected);
  }

  Future<void> _chooseTime() async {
    final selected = await showModalBottomSheet<SafetyTime>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final time in SafetyTime.values)
              ListTile(
                title: Text(_capitalize(time.name)),
                onTap: () => Navigator.pop(context, time),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _time = selected);
  }

  String _capitalize(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  void _selectPoint(ll.LatLng position) {
    setState(() {
      _point = MapPoint(position.latitude, position.longitude);
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
      _error = null;
    });
  }

  void _updateManualPoint() {
    final latitude = double.tryParse(_latitudeController.text);
    final longitude = double.tryParse(_longitudeController.text);
    final point = latitude == null || longitude == null
        ? null
        : MapPoint(latitude, longitude);
    setState(() => _point = point?.isValid == true ? point : null);
  }

  Future<void> _chooseMyLocation() async {
    try {
      final location = await ref
          .read(foregroundLocationServiceProvider)
          .currentLocation();
      if (!mounted) return;
      setState(() {
        _point = location;
        _latitudeController.text = location.latitude.toStringAsFixed(6);
        _longitudeController.text = location.longitude.toStringAsFixed(6);
        _error = null;
      });
      if (_mapReady) {
        _reportMapController.move(
          ll.LatLng(location.latitude, location.longitude),
          15,
        );
      }
    } on LocationException catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error.reason) {
          LocationFailure.denied =>
            'Location permission was denied. Tap the map to choose manually.',
          LocationFailure.permanentlyDenied =>
            'Location access is disabled. Tap the map to choose manually or change access in device settings.',
          LocationFailure.unavailable =>
            'Your location is unavailable. Tap the map to choose manually.',
        },
      );
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Location unavailable. You can still place the pin manually.',
        );
      }
    }
  }

  void _retryMap() {
    setState(() {
      _tileLoadFailed = false;
      _mapGeneration++;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_point == null || !_point!.isValid) {
      setState(
        () => _error = 'Tap the map to place your pin or enter coordinates.',
      );
      return;
    }
    final note = _noteController.text.trim();
    if (!ReportValidation.isValidNote(note)) {
      setState(
        () => _error =
            'Keep the note to ${ReportValidation.maxNoteLength} characters or fewer.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(reportSubmissionProvider)
          .submit(
            point: _point!,
            category: _category,
            time: _time,
            note: note.isEmpty ? null : note,
          );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Report submitted'),
          content: const Text(
            'Your report was saved and is pending review. It will not appear publicly until approved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Back to map'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/safety-map');
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'The report could not be confirmed as saved. Check your connection and retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
