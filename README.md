# WorkoutExporter

**Export your Apple Health workouts to standard fitness formats.**

WorkoutExporter is a native iOS app that lets you export any workout recorded in Apple Health (via any app — Apple Watch, Strava, Nike Run Club, etc.) into industry-standard formats: GPX, TCX, FIT, CSV, JSON, and XML.

No subscription. No account. No tracking. Just your data, your way.

---

## Features

- **6 export formats** — GPX, TCX, FIT (binary), CSV, JSON, XML (Apple Health style)
- **All workout types** — Running, cycling, swimming, hiking, yoga, HIIT, strength training, and 60+ other activity types
- **Complete data extraction** — GPS route, heart rate, cadence, power, speed, swimming strokes, elevation, splits
- **Flexible sharing** — iOS Share Sheet (AirDrop, Mail, Strava, Garmin Connect...) or save directly to the Files app
- **Workout detail view** — Route map (MapKit), heart rate chart (Swift Charts), key stats
- **Search, filter & sort** — Find workouts by name, source app, activity type, date, distance, duration, calories
- **Privacy first** — All data stays on your device. No server, no analytics, no account required

## Screenshots

*(Coming soon)*

## How It Works

1. **Authorize** — On first launch, the app requests read-only access to your Apple Health data
2. **Browse** — All your workouts appear in a scrollable list with key stats (duration, distance, calories, source app)
3. **Explore** — Tap a workout to see the full detail: route map, heart rate graph, and statistics
4. **Export** — Tap the share button, pick a format (GPX, TCX, FIT, CSV, JSON, XML), and share or save the file

### Export Formats Explained

| Format | Type | Best For |
|--------|------|----------|
| **GPX** | XML | Importing into Strava, Garmin Connect, Komoot, etc. Includes GPS trace + heart rate + cadence via Garmin TrackPointExtension |
| **TCX** | XML | Garmin ecosystem. Includes laps, HR, cadence, power, speed via ActivityExtension |
| **FIT** | Binary | Most complete Garmin format. Full activity file with records, laps, sessions. Compatible with Garmin Connect, TrainingPeaks, etc. |
| **CSV** | Text | Data analysis in Excel, Google Sheets, R, Python. Time-series with all data points merged by timestamp |
| **JSON** | Text | Developers, automation, complete raw data dump with all HealthKit fields |
| **XML** | XML | Apple Health Export style — same format as Apple's native "Export All Health Data", scoped to a single workout |

## Tech Stack

- **Language:** Swift 5
- **UI Framework:** SwiftUI with `@Observable` (iOS 17 Observation framework)
- **Minimum Target:** iOS 17.0
- **Frameworks:** HealthKit, MapKit, Swift Charts, CoreLocation
- **Architecture:** MVVM (Model-View-ViewModel)
- **Dependencies:** None — 100% Apple-native, zero third-party libraries

### Key Technical Details

- **Lazy hydration** — The workout list only loads metadata (fast). Full route, heart rate, and sample data are fetched on-demand when you open a workout or export it
- **Concurrent data fetching** — Route, heart rate, cadence, power, and speed are fetched in parallel using Swift async/await and `async let`
- **FIT binary encoder** — Custom implementation of the Garmin FIT protocol: CRC-16, definition/data messages, semicircle coordinates, FIT epoch timestamps, offset altitude encoding
- **Sample-to-trackpoint matching** — Heart rate and cadence samples are matched to GPS points using binary search with a configurable time tolerance
- **XML builder** — Lightweight string-based XML construction (Foundation's `XMLDocument` is macOS-only)

## Project Structure

```
WorkoutExporter/
├── App/                          # App entry point
├── Models/                       # WorkoutData, RoutePoint, SampleTimeSeries, ExportFormat
├── Services/
│   ├── HealthKit/                # HealthKitManager, WorkoutFetcher, RouteFetcher, SampleFetcher
│   └── Export/
│       ├── Formats/              # GPX, TCX, FIT, CSV, JSON, XML exporters
│       └── FIT/                  # Binary FIT encoder (CRC, messages, types)
├── ViewModels/                   # WorkoutList, WorkoutDetail, Export view models
├── Views/                        # SwiftUI views (list, detail, export, onboarding)
└── Utilities/                    # Date/unit formatters, workout type mapping, XML builder
```

## Requirements

- iOS 17.0 or later
- iPhone or iPad
- Xcode 15+ to build from source
- Apple Developer account (required for HealthKit entitlement on physical devices)

## Building from Source

1. Clone the repository
2. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
3. Generate the Xcode project: `cd WorkoutExporter && xcodegen generate`
4. Open `WorkoutExporter.xcodeproj` in Xcode
5. Select your Team in Signing & Capabilities
6. Build and run on a physical device (HealthKit route data is unavailable in the Simulator)

## Privacy

WorkoutExporter reads your health data locally and exports it to files on your device. No data is ever sent to any server. No analytics. No tracking. No account.

See the full [Privacy Policy](https://romanpki.github.io/WorkoutExporter/privacy).

## License

MIT License — see [LICENSE](LICENSE) for details.

## Author

Made by [Roman Potocki](https://github.com/romanpki).
