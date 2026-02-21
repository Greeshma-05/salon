# Local Data Models - Salon Connect

## Overview

This project uses **Hive** for local data storage instead of Firebase. All data is stored locally on the device.

## Models

### 1. Salon
- `id` - Unique identifier
- `name` - Salon name
- `location` - Full address
- `rating` - Average rating (0.0 - 5.0)
- `services` - List of services offered

### 2. Service
- `id` - Unique identifier
- `name` - Service name
- `price` - Service price
- `duration` - Duration in minutes

### 3. Booking
- `id` - Unique identifier
- `salonName` - Name of the salon
- `serviceName` - Name of the service
- `date` - Booking date
- `time` - Booking time

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Hive Adapters

Run the build runner to generate the type adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `lib/models/salon.g.dart`
- `lib/models/service.g.dart`
- `lib/models/booking.g.dart`

### 3. Initialize Hive in main.dart

Update your `main()` function:

```dart
import 'package:flutter/material.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  
  // Optional: Seed sample data for testing
  // await HiveService.seedSampleData();
  
  runApp(const MyApp());
}
```

## Usage Examples

### Add a Salon

```dart
import 'services/hive_service.dart';
import 'models/salon.dart';
import 'models/service.dart';

final salon = Salon(
  id: '1',
  name: 'My Salon',
  location: '123 Main St',
  rating: 4.5,
  services: [
    Service(
      id: 's1',
      name: 'Haircut',
      price: 50.0,
      duration: 45,
    ),
  ],
);

await HiveService.addSalon(salon);
```

### Get All Salons

```dart
final salons = HiveService.getAllSalons();
for (var salon in salons) {
  print('${salon.name} - ${salon.location}');
}
```

### Create a Booking

```dart
import 'models/booking.dart';

final booking = Booking(
  id: 'b1',
  salonName: 'My Salon',
  serviceName: 'Haircut',
  date: DateTime.now().add(Duration(days: 1)),
  time: '10:00 AM',
);

await HiveService.addBooking(booking);
```

### Get Upcoming Bookings

```dart
final upcomingBookings = HiveService.getUpcomingBookings();
for (var booking in upcomingBookings) {
  print('${booking.salonName} - ${booking.formattedDate} at ${booking.time}');
}
```

### Update a Salon

```dart
final salon = HiveService.getSalon('1');
if (salon != null) {
  final updated = salon.copyWith(
    rating: 4.8,
    name: 'Updated Salon Name',
  );
  await HiveService.updateSalon(updated);
}
```

### Delete a Booking

```dart
await HiveService.deleteBooking('b1');
```

## Helper Methods

### Service Model
- `formattedDuration` - Returns duration as "45 min" or "2 hours 30 min"
- `formattedPrice` - Returns price as "$50.00"

### Booking Model
- `formattedDate` - Returns date as "Jan 15, 2026"
- `isPast` - Returns true if booking is in the past
- `isToday` - Returns true if booking is today
- `isUpcoming` - Returns true if booking is upcoming

## Testing

### Seed Sample Data

```dart
await HiveService.seedSampleData();
```

This will create:
- 3 sample salons with services
- 1 sample upcoming booking

### Clear All Data

```dart
await HiveService.clearAllData();
```

## File Structure

```
lib/
├── models/
│   ├── salon.dart          # Salon model
│   ├── salon.g.dart        # Generated adapter
│   ├── service.dart        # Service model
│   ├── service.g.dart      # Generated adapter
│   ├── booking.dart        # Booking model
│   └── booking.g.dart      # Generated adapter
└── services/
    └── hive_service.dart   # Hive operations
```

## Notes

- All data is stored locally using Hive
- No Firebase or internet connection required
- Data persists between app restarts
- Type-safe with code generation
- Fast read/write operations
- Clean and structured code
