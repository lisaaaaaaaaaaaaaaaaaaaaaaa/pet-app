import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/pet_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/pet.dart';
import '../../models/pet_profile.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/premium_feature_dialog.dart';
import '../../widgets/pet/pet_info_card.dart';
import '../../widgets/pet/pet_stats_card.dart';
import '../../widgets/pet/pet_health_card.dart';
import '../../widgets/pet/pet_timeline_card.dart';
import '../../utils/analytics_helper.dart';
import '../../utils/pdf_generator.dart';
import '../../utils/date_formatter.dart';

class PetProfileScreen extends StatefulWidget {
  final String petId;

  const PetProfileScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen>
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
    _loadPetProfile();
    
    AnalyticsHelper.logScreenView('pet_profile', {'pet_id': widget.petId});
  }

  Future<void> _loadPetProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<PetProvider>().loadPetProfile(widget.petId);
    } catch (e) {
      setState(() => _error = 'Failed to load pet profile: $e');
      AnalyticsHelper.logError('pet_profile_load_error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshProfile() async {
    try {
      await context.read<PetProvider>().loadPetProfile(
        widget.petId,
        forceRefresh: true,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to refresh: $e');
    }
  }

  Future<void> _navigateToEditProfile(Pet pet, PetProfile profile) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-pet',
      arguments: {
        'pet': pet,
        'profile': profile,
      },
    );

    if (result == true) {
      _refreshProfile();
      _showSuccessSnackBar('Profile updated successfully');
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'share':
        await _sharePetProfile();
        break;
      case 'export':
        await _exportPetRecords();
        break;
      case 'archive':
        await _showArchiveConfirmation();
        break;
    }
  }

  Future<void> _sharePetProfile() async {
    final pet = context.read<PetProvider>().getPet(widget.petId);
    if (pet == null) return;

    final shareText = '''
${pet.name}'s Pet Profile
Species: ${pet.species}
Breed: ${pet.breed}
Birthday: ${DateFormatter.formatDate(pet.dateOfBirth)}

Download our app to manage your pet's health and care!
''';

    try {
      await Share.share(shareText, subject: '${pet.name}\'s Pet Profile');
      AnalyticsHelper.logEvent('share_pet_profile', {'pet_id': widget.petId});
    } catch (e) {
      _showErrorSnackBar('Failed to share profile: $e');
    }
  }

  Future<void> _exportPetRecords() async {
    if (!_isSubscribed) {
      _showSubscriptionDialog('Export Records');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pet = context.read<PetProvider>().getPet(widget.petId);
      final profile = context.read<PetProvider>().getPetProfile(widget.petId);
      
      if (pet == null || profile == null) {
        throw Exception('Pet data not found');
      }

      final pdfFile = await PdfGenerator.generatePetReport(pet, profile);
      await Share.shareFiles(
        [pdfFile.path],
        text: '${pet.name}\'s Health Records',
      );
      
      AnalyticsHelper.logEvent('export_pet_records', {'pet_id': widget.petId});
    } catch (e) {
      _showErrorSnackBar('Failed to export records: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      
      _showSuccessSnackBar('Pet archived successfully');
      Navigator.pop(context, true);
      
      AnalyticsHelper.logEvent('archive_pet', {'pet_id': widget.petId});
    } catch (e) {
      _showErrorSnackBar('Failed to archive pet: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSubscriptionDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => PremiumFeatureDialog(
        title: 'Premium Feature',
        content: '$feature is a premium feature. '
                'Upgrade to unlock this and other premium features!',
        onUpgrade: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/subscription');
        },
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _refreshProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          final pet = provider.getPet(widget.petId);
          final profile = provider.getPetProfile(widget.petId);

          if (_error != null) {
            return ErrorView(
              message: _error!,
              onRetry: _loadPetProfile,
            );
          }

          if (pet == null || profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  _buildSliverAppBar(pet),
                  _buildSliverPersistentHeader(),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(pet, profile),
                    PetHealthCard(
                      pet: pet,
                      profile: profile,
                      isSubscribed: _isSubscribed,
                    ),
                    PetTimelineCard(
                      petId: widget.petId,
                      isSubscribed: _isSubscribed,
                    ),
                    _buildGalleryTab(pet, profile),
                  ],
                ),
              ),
              if (_isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
              child: const Icon(Icons.pets, size: 64),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            final pet = context.read<PetProvider>().getPet(widget.petId);
            final profile = context.read<PetProvider>().getPetProfile(widget.petId);
            if (pet != null && profile != null) {
              _navigateToEditProfile(pet, profile);
            }
          },
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
            Tab(text: 'Info'),
            Tab(text: 'Health'),
            Tab(text: 'Timeline'),
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

  Widget _buildInfoTab(Pet pet, PetProfile profile) {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PetInfoCard(pet: pet, profile: profile),
          const SizedBox(height: 16),
          PetStatsCard(pet: pet, profile: profile),
        ],
      ),
    );
  }

  Widget _buildGalleryTab(Pet pet, PetProfile profile) {
    if (!_isSubscribed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Premium Feature',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upgrade to access the photo gallery',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/subscription'),
              child: const Text('UPGRADE NOW'),
            ),
          ],
        ),
      );
    }

    // Implement gallery view here
    return const Center(child: Text('Gallery Coming Soon'));
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        if (!_isSubscribed) {
          _showSubscriptionDialog('Quick Actions');
          return;
        }
        _showQuickActionsMenu();
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add),
    );
  }

  void _showQuickActionsMenu() {
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
                Navigator.pushNamed(
                  context,
                  '/add-health-record',
                  arguments: widget.petId,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Schedule Reminder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/add-reminder',
                  arguments: widget.petId,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Add Photo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/add-photo',
                  arguments: widget.petId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
