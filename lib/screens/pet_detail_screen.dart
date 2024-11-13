import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet.dart';
import '../../theme/app_theme.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPetDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPetDetails() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().loadPetDetails(widget.pet.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pet details: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            _buildSliverPersistentHeader(),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildHealthTab(),
                  _buildCareTab(),
                  _buildGalleryTab(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActionsMenu,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'pet_image_${widget.pet.id}',
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.pet.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
        title: Text(widget.pet.name),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.pushNamed(
            context,
            '/edit-pet',
            arguments: widget.pet,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Text('Share Profile'),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Text('Export Records'),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Text('Archive Pet'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliverPersistentHeader() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Health'),
            Tab(text: 'Care'),
            Tab(text: 'Gallery'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildUpcomingEvents(),
          const SizedBox(height: 16),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Species', widget.pet.species),
            _buildInfoRow('Breed', widget.pet.breed),
            _buildInfoRow(
              'Birthday',
              DateFormat('MMMM d, y').format(widget.pet.birthday),
            ),
            _buildInfoRow('Gender', widget.pet.gender),
            _buildInfoRow('Weight', '${widget.pet.weight} kg'),
            if (widget.pet.microchipId != null)
              _buildInfoRow('Microchip ID', widget.pet.microchipId!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.medical_services,
                  label: 'Vaccinations',
                  value: widget.pet.stats.vaccinations.toString(),
                ),
                _buildStatItem(
                  icon: Icons.healing,
                  label: 'Conditions',
                  value: widget.pet.stats.conditions.toString(),
                ),
                _buildStatItem(
                  icon: Icons.calendar_today,
                  label: 'Checkups',
                  value: widget.pet.stats.checkups.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/calendar'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = widget.pet.upcomingEvents;
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('No upcoming events'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getEventColor(event.type),
            child: Icon(
              _getEventIcon(event.type),
              color: Colors.white,
            ),
          ),
          title: Text(event.title),
          subtitle: Text(
            DateFormat('MMM d, y - h:mm a').format(event.date),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to event details
          },
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimeline() {
    final activities = widget.pet.recentActivities;
    if (activities.isEmpty) {
      return const Center(
        child: Text('No recent activities'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length.clamp(0, 5),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getActivityColor(activity.type),
            child: Icon(
              _getActivityIcon(activity.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(activity.description),
          subtitle: Text(
            DateFormat('MMM d, y - h:mm a').format(activity.date),
          ),
        );
      },
    );
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Colors.blue;
      case 'checkup':
        return Colors.green;
      case 'grooming':
        return Colors.purple;
      case 'medication':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines;
      case 'checkup':
        return Icons.health_and_safety;
      case 'grooming':
        return Icons.brush;
      case 'medication':
        return Icons.medication;
      default:
        return Icons.event;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'health':
        return Colors.red;
      case 'care':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'exercise':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'care':
        return Icons.pets;
      case 'food':
        return Icons.restaurant;
      case 'exercise':
        return Icons.directions_run;
      default:
        return Icons.circle;
    }
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  Widget _buildQuickActionsSheet() {
    final actions = [
      {
        'icon': Icons.event,
        'title': 'Schedule Appointment',
        'route': '/schedule-appointment',
      },
      {
        'icon': Icons.medication,
        'title': 'Add Medication',
        'route': '/add-medication',
      },
      {
        'icon': Icons.note_add,
        'title': 'Add Health Record',
        'route': '/add-health-record',
      },
      {
        'icon': Icons.photo_camera,
        'title': 'Add Photo',
        'route': '/add-photo',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => ListTile(
                leading: Icon(action['icon'] as IconData),
                title: Text(action['title'] as String),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    action['route'] as String,
                    arguments: widget.pet,
                  );
                },
              )),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        // Implement share functionality
        break;
      case 'export':
        // Implement export functionality
        break;
      case 'archive':
        _showArchiveConfirmation();
        break;
    }
  }

  void _showArchiveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Pet'),
        content: const Text(
          'Are you sure you want to archive this pet? '
          'Archived pets will be hidden from the main view.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement archive functionality
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}