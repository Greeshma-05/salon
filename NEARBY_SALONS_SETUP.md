# Nearby Salons Feature - Setup Guide

## Overview
The app now includes a location-based salon discovery feature with Firebase backend integration. Users can find nearby salons by:
- **Detecting current location** (GPS)
- **Manual location entry** (latitude/longitude)
- **Location search** (city/area name)

## Components Created

### 1. **Location Service** (`lib/services/location_service.dart`)
- Handles geolocation with permission management
- Calculates distances using Haversine formula
- Queries Firebase for nearby salons
- Methods:
  - `requestLocationPermission()` - Request GPS access
  - `getCurrentLocation()` - Get user's current coordinates
  - `getNearbySalons(latitude, longitude, radiusKm)` - Find salons within radius
  - `searchSalonsByLocation(locationQuery)` - Search by city/area
  - `updateSalonLocation(salonId, lat, lon)` - Admin: Update salon coordinates

### 2. **Nearby Salons Widget** (`lib/screens/customer/nearby_salons_widget.dart`)
- Prominent UI on customer home screen
- Features:
  - Search bar (location text search)
  - "Detect Location" button (GPS auto-detect)
  - "Manual Entry" button (enter coordinates)
  - Adjustable search radius slider (1-50 km)
  - Salon cards showing distance and services
  - Error handling and loading states

### 3. **Updated Salon Model** (`lib/models/salon.dart`)
- Added fields:
  - `latitude` - Salon's latitude coordinate
  - `longitude` - Salon's longitude coordinate
  - `distanceKm` - Calculated distance (runtime only)
- New factory method:
  - `Salon.fromMap()` - Create from Firestore data

## Firebase Setup

### Step 1: Update Firestore Salon Documents
Add location coordinates to each salon in Firestore:

```json
{
  "id": "salon_1",
  "name": "Luxury Salon",
  "location": "New Delhi",
  "latitude": 28.7041,
  "longitude": 77.1025,
  "rating": 4.5,
  "services": [...]
}
```

**Example locations for testing (Delhi):**
- Connaught Place: 28.6328, 77.2197
- Khan Market: 28.5697, 77.2289
- Saket: 28.5244, 77.1855
- Karol Bagh: 28.6478, 77.1892

### Step 2: Create Firestore Index (Optional)
For optimized location queries, create a composite index in Firestore:
- Collection: `salons`
- Fields: `latitude` (Ascending), `longitude` (Ascending)

Visit: Firebase Console → Firestore → Indexes → Create Index

## Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Already configured in geolocator plugin.

## iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby salons</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to find nearby salons</string>
```

## Usage

### Customer-side (automatic):
1. Open home screen → "Find Nearby Salons" section appears
2. Click "Detect Location" to use GPS
3. Or enter coordinates manually
4. Or search by city/area name
5. Adjust radius slider to expand/contract search
6. Tap any salon to view details

### Admin-side (adding salon locations):
```dart
final locationService = LocationService();
await locationService.updateSalonLocation(
  'salon_id',
  28.7041,  // latitude
  77.1025,  // longitude
);
```

## Distance Calculation
Uses **Haversine formula** for accurate great-circle distances between coordinates. Accounts for Earth's curvature.

## API Dependencies

**Added to pubspec.yaml:**
- `geolocator: ^12.0.0` - Location services
- `cloud_firestore: ^5.0.0` - Firebase database
- `firebase_core: ^3.0.0` - Firebase initialization

Run `flutter pub get` after updates.

## Testing

### Test Locations (Delhi area):
```
1. Connaught Place: 28.6328, 77.2197
2. Khan Market: 28.5697, 77.2289
3. Saket: 28.5244, 77.1855
4. Karol Bagh: 28.6478, 77.1892
```

Manual entry: Click "Manual Entry" → Enter coordinates → Search

### Distance between Connaught Place and Khan Market: ~7 km

## Error Handling
- Location permission denied → User prompted to enable
- GPS timeout → Falls back to manual entry
- Firebase unavailable → Shows error message
- No salons found → Shows "No salons in this area"

## Future Enhancements
1. Map view integration (Google Maps)
2. Favorite/bookmark nearby salons
3. Real-time location tracking
4. Salon opening hours display
5. Weather-based salon recommendations
