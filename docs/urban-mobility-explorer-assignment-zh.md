# iOS App - Urban Mobility Explorer Assignment

## Project Goal
Build an iOS app for exploring urban mobility stations, such as bike-sharing or scooter-sharing stations. Users should be able to browse available stations, view station details, and save favorite stations.

This assignment evaluates senior-level iOS engineering: architecture, UI state management, data handling, persistence, error handling, maintainability, and practical trade-offs.

---

## Time Expectation
Please submit your solution within 48 hours. We expect around **6-8 focused development hours**, not 48 hours of work.  
Prioritize a reliable, understandable implementation over a large feature set.

---

## Requirements
- iOS only, Swift
- SwiftUI preferred; UIKit acceptable
- Minimum deployment target: iOS 16
- Use `async/await` where appropriate
- The app must build, run, and include a working UI
- Do not submit hardcoded secrets, API keys, or tokens

---

## Data
Use realistic urban mobility station data. You may use a real open API, public dataset, sample JSON, mock server, or local data provider. The project should remain reviewable even if network access is unavailable.

Possible data sources include:
- CityBikes API
- GBFS public feeds
- OpenStreetMap/Nominatim
- Open-Meteo for optional weather-related enhancements
- Other public mobility/location APIs

---

## Must Have Features
### 1. Station List
Show a station list with meaningful availability information. The list should support common user flows such as:
- Loading states
- Empty/error states
- Refresh
- Search
- Sorting or filtering (where appropriate)

### 2. Station Detail
Provide a detail screen for a selected station. Include enough information for a user to understand the station, its location, and its current availability.

### 3. Favorites
Allow users to save and revisit favorite stations. Favorites should persist across app launches and remain useful even when fresh data cannot be loaded.

---

## AI Tool Usage
You may use AI tools such as ChatGPT, GitHub Copilot, Cursor, Claude, Gemini, or similar tools.  
You are responsible for the final submission. During the follow-up interview, you may be asked to:
- Explain your architecture
- Walk through important code paths
- Discuss trade-offs
- Make a small change to your submission

If you use AI tools, briefly mention what they helped with and how you verified the AI-assisted work.

---

## Bonus Points (Optional)
Optional items are not required. Choose only the ones that improve the quality of your solution:
- Caching, fallback behavior, stale-data handling, or retry strategy
- Lightweight smart recommendation or scoring for station usefulness without requiring any external AI API key
- Unit/UI tests for important business logic, persistence, state management, or data handling
- MapKit, Apple Maps, CoreLocation, or graceful permission handling
- Weather or contextual data integration
- Strong accessibility, Dynamic Type, light/dark mode, or large-list performance
- Clear architecture boundaries, dependency injection, protocol-based providers, or modularization
- Concurrency safety, request cancellation, actor-based cache protection, or structured logging
- CI, linting, formatting, snapshot tests, or architecture decision notes

---

## Evaluation Focus
We will mainly evaluate:
- Architecture and modularity
- iOS UI and state management
- Data handling and error handling
- Local persistence and favorites behavior
- Code readability and maintainability
- Delivery completeness
- Ability to explain trade-offs and take ownership of the final solution

We do not expect a perfect production app. We expect a senior engineer to make practical decisions, communicate trade-offs clearly, and deliver a reliable, understandable solution.
