import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/subscription.dart';
import '../widgets/subscription_card.dart';
import '../core/constants/app_colors.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
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
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final calendarData = ref.watch(calendarDataProvider);
    final selectedSubscriptions = _selectedDay != null
        ? ref.watch(subscriptionsForDateProvider(_selectedDay!))
        : <Subscription>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Glow Ornament
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.1),
                    blurRadius: 80,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Column(
            children: [
              // Spacing for transparent AppBar
              SizedBox(height: kToolbarHeight + 40),

              // Calendar Widget
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.05,
                  ), // Glassmorphism transparent
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,

                  // Header Style
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    leftChevronIcon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    rightChevronIcon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Days of Week Style
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    weekendStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),

                  // Calendar Style
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    outsideTextStyle: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                    ),

                    // Today Decoration
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    todayTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),

                    // Selected Decoration
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),

                    // Marker Decoration
                    markersMaxCount: 3,
                    markerSize: 6,
                    markerDecoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
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
                    final normalizedDay = DateTime(
                      day.year,
                      day.month,
                      day.day,
                    );
                    return calendarData[normalizedDay] ?? [];
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;

                      // Check if any event is urgent

                      return Positioned(
                        bottom: 5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: events.take(3).map((_) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Selected Date Header & List
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_selectedDay != null) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMMM d').format(_selectedDay!),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('EEEE').format(_selectedDay!),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedSubscriptions.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Text(
                                    '${selectedSubscriptions.length} Items',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      // List
                      Expanded(
                        child: selectedSubscriptions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedDay == null
                                          ? Icons.touch_app_rounded
                                          : Icons.event_busy_rounded,
                                      size: 48,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _selectedDay == null
                                          ? 'Select a date to view subscriptions'
                                          : 'No subscriptions on this date',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: selectedSubscriptions.length,
                                itemBuilder: (context, index) {
                                  final subscription =
                                      selectedSubscriptions[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: SubscriptionCard(
                                      subscription: subscription,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriptionDetailScreen(
                                                  subscriptionId:
                                                      subscription.id,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
