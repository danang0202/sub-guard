import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/subscription.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize subscription data lazily
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
      // Initialize subscription list provider if not already done
      await ref.read(subscriptionListProvider.notifier).initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize calendar data: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Show UI even if load fails
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final calendarData = ref.watch(calendarDataProvider);
    final selectedSubscriptions = _selectedDay != null
        ? ref.watch(subscriptionsForDateProvider(_selectedDay!))
        : <Subscription>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          // Calendar widget
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                // Default day style
                defaultTextStyle: const TextStyle(color: Colors.white),
                weekendTextStyle: const TextStyle(color: Colors.white70),
                outsideTextStyle: TextStyle(color: Colors.grey[600]),
                // Today style
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF03DAC6).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                // Selected day style
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFBB86FC),
                  shape: BoxShape.circle,
                ),
                // Marker style
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF03DAC6),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.grey[400]),
                weekendStyle: TextStyle(color: Colors.grey[400]),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return calendarData[normalizedDay] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;

                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final daysUntil = normalizedDay
                      .difference(
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                      )
                      .inDays;

                  Color markerColor;
                  if (daysUntil < 0) {
                    markerColor = const Color(0xFFFF5252); // Red for overdue
                  } else if (daysUntil <= 1) {
                    markerColor = const Color(0xFFFF5252); // Red for critical
                  } else if (daysUntil <= 7) {
                    markerColor = const Color(0xFFFFC107); // Yellow for warning
                  } else {
                    markerColor = const Color(0xFF4CAF50); // Green for safe
                  }

                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Selected date subscriptions
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDay!),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (selectedSubscriptions.isNotEmpty)
                    Text(
                      '${selectedSubscriptions.length} subscription${selectedSubscriptions.length != 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Subscriptions list
          Expanded(
            child: selectedSubscriptions.isEmpty
                ? Center(
                    child: Text(
                      _selectedDay == null
                          ? 'Select a date to view subscriptions'
                          : 'No subscriptions on this date',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedSubscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription = selectedSubscriptions[index];
                      return SubscriptionCard(
                        subscription: subscription,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubscriptionDetailScreen(
                                subscriptionId: subscription.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
