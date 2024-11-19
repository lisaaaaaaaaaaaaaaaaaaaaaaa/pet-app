import 'package:flutter/material.dart';
import '../widgets/weight_chart.dart';
import '../widgets/wellness_summary_card.dart';
import '../widgets/background_circles.dart';
import '../widgets/notification_card.dart';
import '../models/pet_profile.dart';
import '../models/wellness_data.dart';
import '../models/weight_record.dart';
import '../models/notification_item.dart';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';
import '../utils/date_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  late Future<List<PetProfile>> _petsFuture;
  late Future<WellnessData> _wellnessFuture;
  late Future<List<WeightRecord>> _weightsFuture;
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _logScreenView();
  }

  Future<void> _logScreenView() async {
    await _analytics.logScreenView(screenName: 'Dashboard');
  }

  void _initializeData() {
    _petsFuture = _fetchPets();
    _wellnessFuture = _fetchWellnessData();
    _weightsFuture = _fetchWeightRecords();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<PetProfile>> _fetchPets() async {
    // Implement your pet fetching logic here
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return [
      PetProfile(
        id: '1',
        name: 'Max',
        type: 'Dog',
        breed: 'Golden Retriever',
        age: 5,
        weight: 30.5,
        imageUrl: 'https://example.com/max.jpg',
      ),
      // Add more pets as needed
    ];
  }

  Future<WellnessData> _fetchWellnessData() async {
    // Implement your wellness data fetching logic here
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return WellnessData(
      overallScore: 8,
      activityScore: 7,
      appetiteScore: 9,
      sleepScore: 8,
      moodScore: 8,
      activityTrend: TrendDirection.up,
      appetiteTrend: TrendDirection.stable,
      sleepTrend: TrendDirection.stable,
      moodTrend: TrendDirection.up,
      notes: 'Overall wellness is good.',
      concerns: null,
      recommendations: 'Maintain current routine.',
    );
  }

  Future<List<WeightRecord>> _fetchWeightRecords() async {
    // Implement your weight records fetching logic here
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return List.generate(
      30,
      (index) => WeightRecord(
        date: DateTime.now().subtract(Duration(days: 29 - index)),
        weight: 30.0 + (index * 0.1),
      ),
    );
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    // Implement your notifications fetching logic here
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return [
      NotificationItem(
        id: '1',
        title: 'Vaccination Due',
        message: 'Max\'s annual vaccination is due next week',
        timestamp: DateTime.now(),
        type: NotificationType.reminder,
        action: 'Schedule Now',
      ),
      // Add more notifications as needed
    ];
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundCircles(
            circleCount: 3,
            animate: true,
          ),
          RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.primaryColor.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Navigate to notifications screen
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Navigate to settings screen
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPetsList(),
            const SizedBox(height: 24),
            _buildWellnessSection(),
            const SizedBox(height: 24),
            _buildWeightSection(),
            const SizedBox(height: 24),
            _buildNotificationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsList() {
    return FutureBuilder<List<PetProfile>>(
      future: _petsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final pets = snapshot.data ?? [];
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pets.length + 1,
            itemBuilder: (context, index) {
              if (index == pets.length) {
                return _buildAddPetCard();
              }
              return _buildPetCard(pets[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildPetCard(PetProfile pet) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          // Navigate to pet details
        },
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(pet.imageUrl),
              ),
              const SizedBox(height: 8),
              Text(
                pet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                pet.breed,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPetCard() {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          // Navigate to add pet screen
        },
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add Pet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessSection() {
    return FutureBuilder<WellnessData>(
      future: _wellnessFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final wellnessData = snapshot.data!;
        return WellnessSummaryCard(
          data: wellnessData,
          onTap: () {
            // Navigate to wellness details
          },
        );
      },
    );
  }

  Widget _buildWeightSection() {
    return FutureBuilder<List<WeightRecord>>(
      future: _weightsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final weightRecords = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight Tracking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            WeightChart(
              records: weightRecords,
              days: 30,
              height: 200,
              showGrid: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationsSection() {
    return FutureBuilder<List<NotificationItem>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notifications = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all notifications
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...notifications.map((notification) => NotificationCard(
              notification: notification,
              onTap: () {
                // Handle notification tap
              },
              onDismiss: () {
                // Handle notification dismiss
              },
            )),
          ],
        );
      },
    );
  }
}
