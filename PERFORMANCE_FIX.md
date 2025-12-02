# Performance Optimization Fix

## Masalah yang Ditemukan

Aplikasi SUB-GUARD mengalami masalah performa yang menyebabkan:
1. **Frame Skipping**: 83+ frames skipped (>1.3 detik freeze)
2. **Lost Connection**: Aplikasi terputus dari device/emulator
3. **Main Thread Blocking**: Terlalu banyak pekerjaan berat di main thread

### Root Causes

1. **Heavy Initialization Work**
   - `initState` melakukan banyak operasi async yang blocking
   - Permission checks dan battery optimization checks dilakukan secara synchronous
   - Notification settings initialization blocking UI thread

2. **Inefficient Provider Computations**
   - `upcomingBillsProvider`: Iterasi dan filtering yang tidak optimal
   - `calendarDataProvider`: Redundant date normalization
   - Multiple `DateTime.now()` calls per rebuild

3. **Screen Management**
   - Bottom navigation rebuilding semua screens setiap tab switch
   - Tidak ada state preservation antar tab

## Solusi yang Diterapkan

### 1. Optimized App Initialization (`lib/app/app.dart`)

**Sebelum:**
```dart
Future.delayed(const Duration(seconds: 1), () async {
  ref.read(notificationSettingsHandlerProvider).initialize();
  await _requestPermissions();
  await _checkBatteryOptimization();
});
```

**Sesudah:**
```dart
Future.delayed(const Duration(seconds: 2), () async {
  try {
    ref.read(notificationSettingsHandlerProvider).initialize();
  } catch (e) {
    debugPrint('Failed to initialize notification settings: $e');
  }
  _initializeBackgroundTasks(); // Non-blocking
});
```

**Keuntungan:**
- ✅ UI render lebih cepat (delay 2 detik memberi waktu untuk stabilisasi)
- ✅ Background tasks tidak blocking main thread
- ✅ Error handling mencegah crash

### 2. Optimized Provider Computations (`lib/providers/computed_providers.dart`)

**upcomingBillsProvider - Sebelum:**
```dart
return subscriptions.where((subscription) {
  final billingDate = DateTime(...); // Repeated for every subscription
  return subscription.isActive && ...;
}).toList()..sort(...);
```

**upcomingBillsProvider - Sesudah:**
```dart
// Pre-filter active subscriptions first
final activeSubscriptions = subscriptions.where((s) => s.isActive);

// Then filter by date range with for loop (more efficient)
final upcoming = <Subscription>[];
for (final subscription in activeSubscriptions) {
  final billingDate = DateTime(...); // Only once per subscription
  if (!billingDate.isBefore(today) && billingDate.isBefore(thirtyDaysLater)) {
    upcoming.add(subscription);
  }
}
upcoming.sort(...);
return upcoming;
```

**Keuntungan:**
- ✅ Pre-filtering mengurangi jumlah iterasi
- ✅ For loop lebih efisien dari chained `where` operations
- ✅ DateTime calculations di-cache

**calendarDataProvider - Sebelum:**
```dart
for (final subscription in subscriptions) {
  if (!subscription.isActive) continue; // Check in every iteration
  if (calendarData.containsKey(date)) {
    calendarData[date]!.add(subscription);
  } else {
    calendarData[date] = [subscription];
  }
}
```

**calendarDataProvider - Sesudah:**
```dart
// Pre-filter active subscriptions
final activeSubscriptions = subscriptions.where((s) => s.isActive);

for (final subscription in activeSubscriptions) {
  calendarData.putIfAbsent(date, () => []).add(subscription);
}
```

**Keuntungan:**
- ✅ Pre-filtering mengurangi iterasi
- ✅ `putIfAbsent` lebih clean dan efisien
- ✅ Reduced conditional checks

### 3. Optimized Screen Management (`lib/screens/main_navigation_screen.dart`)

**Sebelum:**
```dart
final List<Widget> _screens = [...];
body: _screens[_currentIndex], // Rebuilds on every tab switch
```

**Sesudah:**
```dart
static const List<Widget> _screens = [...]; // Static const
body: IndexedStack(
  index: _currentIndex,
  children: _screens,
), // Preserves state across tabs
```

**Keuntungan:**
- ✅ `IndexedStack` mempertahankan state semua screens
- ✅ Tidak ada rebuild saat tab switch
- ✅ Static const mencegah recreation

## Expected Results

Setelah optimasi ini, aplikasi seharusnya:
- ✅ **Startup lebih cepat**: UI muncul dalam <500ms
- ✅ **Tidak ada frame skipping**: Smooth 60fps
- ✅ **Tidak disconnect**: Main thread tidak overload
- ✅ **Tab switching instant**: IndexedStack preserves state
- ✅ **Better error handling**: Crash-resistant initialization

## Testing Checklist

Setelah restart app, periksa:
- [ ] App launches without "Skipped X frames" warnings
- [ ] No "Lost connection to device" errors
- [ ] Dashboard loads smoothly
- [ ] Tab switching is instant
- [ ] Calendar view renders without lag
- [ ] No ANR (Application Not Responding) dialogs

## Additional Recommendations

### 1. Monitor Provider Performance
Jika masih ada lag, tambahkan logging:

```dart
final upcomingBillsProvider = Provider<List<Subscription>>((ref) {
  final stopwatch = Stopwatch()..start();
  final result = /* computation */;
  debugPrint('upcomingBillsProvider took ${stopwatch.elapsedMilliseconds}ms');
  return result;
});
```

### 2. Consider Pagination
Jika subscription list sangat besar (>100 items), pertimbangkan pagination atau lazy loading.

### 3. Profile dengan DevTools
Gunakan Flutter DevTools untuk profiling:
```bash
flutter run --profile
```
Kemudian buka DevTools untuk melihat performance timeline.

### 4. Check BootReceiver
Jika masih ada masalah dengan "Boot already handled", pertimbangkan untuk menonaktifkan sementara BootReceiver saat development:

```kotlin
// In AndroidManifest.xml, comment out:
<!-- <receiver android:name=".BootReceiver" ... /> -->
```

## Performance Metrics

### Target Metrics
- **App startup**: < 2 seconds to first frame
- **Frame rendering**: 60fps (16.67ms/frame)
- **Provider computation**: < 50ms per rebuild
- **Tab switching**: < 100ms

### How to Monitor
```bash
# Run with performance overlay
flutter run --profile

# Or add to code:
MaterialApp(
  showPerformanceOverlay: true,
  ...
)
```

## Troubleshooting

### Masih ada frame skipping?
1. Check log untuk provider yang lambat
2. Pastikan tidak ada synchronous file I/O
3. Profile dengan Flutter DevTools

### Masih lost connection?
1. Increase emulator RAM (Settings > Advanced > RAM)
2. Cold boot emulator (Tools > AVD Manager > Cold Boot Now)
3. Try on physical device

### BootReceiver masih muncul?
Ini normal saat development karena hot reload/restart. Ignore selama tidak ada crash.

---

**Catatan**: Setelah perubahan ini, lakukan `flutter clean` dan rebuild:
```bash
flutter clean
flutter pub get
flutter run
```
