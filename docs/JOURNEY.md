# Journey Guardian (screens 23–24)

The journey flow is an on-device foreground preview. Users can enter a destination label, choose 15/30/45 minutes, and opt into the Guardian preview. The destination is not geocoded and no road route is calculated. The monitoring screen shows OpenStreetMap centered on India until the user explicitly requests foreground location; it never shows a fabricated route or remote location.

Arrival detection, trusted-contact location sharing, battery handoff, and SOS message delivery are not configured. The app does not collect or send location in the background, persist journeys, or notify contacts. The user can manually end the on-device preview with “Confirm arrival.” Call 112 opens the system phone app after confirmation and Kavach cannot confirm connection. These limits are stated in the screens so the visual concept is not mistaken for a working background safety service.
# Journey destination search

Starting a journey sends the destination text only after the user presses
**Start Journey**. The app makes one Nominatim search request (no autocomplete)
and opens the in-app OpenStreetMap view centered on the returned destination
with a destination marker. The app does not draw a route or claim directions
are available. On entering the journey map, Kavach requests foreground location
and centers there when access is granted; if access is denied or unavailable,
the map stays centered on the selected destination. The destination marker
remains available through the “Show destination” map control. Search failures
and no-result responses keep the user on the form with a retryable message.
Destination text is sent to OpenStreetMap's
public geocoding service; users should not enter private or identifying notes.

The public Nominatim endpoint is a limited-capacity, best-effort service. Its
policy allows user-triggered searches for moderate traffic, requires an
identifying User-Agent and attribution, and forbids client-side autocomplete.
Before broader production use, configure a replaceable provider with caching
or a suitable hosted/self-hosted service. See the [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/).
