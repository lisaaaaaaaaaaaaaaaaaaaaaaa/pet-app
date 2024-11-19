import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/pet_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/pet.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/pet/pet_health_card.dart';
import '../../widgets/pet/pet_care_card.dart';
import '../../widgets/pet/pet_gallery_card.dart';
import '../../utils/analytics_helper.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _isSubscribed = context.read<SubscriptionProvider>().isSubscribed;
    _loadPetDetails();
    
    // Track screen view
    AnalyticsHelper.logScreenView('pet_detail', {'pet_id': widget.petId});
  }

  Future<void> _loadPetDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<PetProvider>().loadPetDetails(widget.petId);
    } catch (e) {
      setState(() => _error = 'Failed to load pet details: $e');
      AnalyticsHelper.logError('pet_detail_load_error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showQuickActionsMenu() {
    if (!_isSubscribed) {
      _showSubscriptionDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Add Health Record'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddHealthRecord();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Schedule Appointment'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScheduleAppointment();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Add Photo'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
          'This feature is only available to premium subscribers. '
          'Would you like to upgrade your subscription?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NOT NOW'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('UPGRADE'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddHealthRecord() async {
    final result = await Navigator.pushNamed(
      context,
      '/add-health-record',
      arguments: widget.petId,
    );

    if (result == true) {
      _loadPetDetails();
    }
  }

  Future<void> _navigateToScheduleAppointment() async {
    final result = await Navigator.pushNamed(
      context,
      '/schedule-appointment',
      arguments: widget.petId,
    );

    if (result == true) {
      _loadPetDetails();
    }
  }

  Future<void> _navigateToAddPhoto() async {
    final result = await Navigator.pushNamed(
      context,
      '/add-photo',
      arguments: widget.petId,
    );

    if (result == true) {
      _loadPetDetails();
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'share':
        // Implement share functionality
        break;
      case 'export':
        if (!_isSubscribed) {
          _showSubscriptionDialog();
          return;
        }
        // Implement export functionality
        break;
      case 'archive':
        await _showArchiveConfirmation();
        break;
    }
  }

  Future<void> _showArchiveConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Archive Pet Profile',
        content: 'This will hide the pet profile from your main list. '
                'You can restore it later from the archived pets section.',
        confirmText: 'Archive',
        isDestructive: true,
      ),
    );

    if (confirmed == true) {
      await _archivePet();
    }
  }

  Future<void> _archivePet() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().archivePet(widget.petId);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet archived successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to archive pet: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: _error!,
          onRetry: _loadPetDetails,
        ),
      );
    }

    return Scaffold(
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          final pet = provider.getPet(widget.petId);
          
          if (pet == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(pet),
              _buildSliverPersistentHeader(),
            ],
            body: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(pet),
                    PetHealthCard(petId: widget.petId),
                    PetCareCard(petId: widget.petId),
                    PetGalleryCard(
                      petId: widget.petId,
                      isSubscribed: _isSubscribed,
                    ),
                  ],
                ),
                if (_isLoading) const LoadingOverlay(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActionsMenu,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSliverAppBar(Pet pet) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(pet.name),
        background: Hero(
          tag: 'pet_image_${pet.id}',
          child: CachedNetworkImage(
            imageUrl: pet.photoUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.pushNamed(
            context,
            '/edit-pet',
            arguments: pet,
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

  Widget _buildOverviewTab(Pet pet) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(pet),
        const SizedBox(height: 16),
        _buildStatsCard(pet),
        const SizedBox(height: 16),
        _buildUpcomingEvents(pet),
        const SizedBox(height: 16),
        _buildRecentActivities(pet),
      ],
    );
  }

  // ... [Previous UI building methods remain the same]

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
