# Urban Mobility Explorer

Urban Mobility Explorer is an iOS 16+ SwiftUI app for browsing shared mobility stations, checking station availability, and saving frequently used stations.

## Features

### Station List

- Browse stations by selected network.
- Switch between CityBikes networks.
- Search stations by name or address.
- Sort by available bikes, open docks, or name.
- Handles loading, empty, error, refresh, cached, and offline states.

### Favorites

- Add or remove favorites from the station detail screen.
- Access saved stations from the Favorites tab.
- Persist favorites locally across app launches.

### Detail View

- Show station name, address, and coordinates.
- Show available bikes, open docks, and last update time.
- Toggle favorite status directly from the detail screen.

### Settings

- Switch appearance between system, light, and dark mode.
- Show basic app and review-readiness information.

## Architecture

The app uses a lightweight layered architecture:

```text
UrbanMobilityExplorer
├── App
├── Domain
├── Data
├── Features
├── SharedUI
└── Resources
```

- `App`: dependency assembly through `AppContainer`.
- `Domain`: models, repository protocols, and use cases.
- `Data`: CityBikes API service, mappers, repositories, cache stores, and offline data source.
- `Features`: SwiftUI screens and view models for Stations, Favorites, and Settings.
- `SharedUI`: reusable UI components.
- `Resources`: bundled offline JSON data.

Station loading follows `live -> cache -> offline`. Cache writes are best effort, so fresh live data can still be shown if local cache saving fails.
