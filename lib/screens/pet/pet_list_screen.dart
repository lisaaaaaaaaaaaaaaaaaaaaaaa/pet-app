import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/pet_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/pet.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/premium_feature_dialog.dart';
import '../../widgets/pet/pet_list_item.dart';
import '../../utils/analytics_helper.dart';
import '../../utils/debouncer.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({Key? key}) : super(key: key);

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  bool _isLoading = false;
  String? _error;
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  PetFilter _currentFilter = PetFilter.active;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _isSubscribed = context.read<SubscriptionProvider>().isSubscribed;
    _loadPets();
    AnalyticsHelper.logScreenView('pet_list');
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<PetProvider>().loadPets(
        filter: _currentFilter,
        searchQuery: _searchController.text,
      );
    } catch (e) {
      setState(() => _error = 'Failed to load pets: $e');
      AnalyticsHelper.logError('pet_list_load_error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPets() async {
    try {
      await context.read<PetProvider>().loadPets(
        filter: _currentFilter,
        searchQuery: _searchController.text,
        forceRefresh: true,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to refresh: $e');
    }
  }

  Future<void> _navigateToAddPet() async {
    final petProvider = context.read<PetProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    if (!_isSubscribed && 
        petProvider.pets.length >= subscriptionProvider.freeTierPetLimit) {
      _showSubscriptionDialog();
      return;
    }

    final result = await Navigator.pushNamed(context, '/add-pet');
    
    if (result == true) {
      _refreshPets();
      _showSuccessSnackBar('Pet added successfully!');
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => PremiumFeatureDialog(
        title: 'Pet Limit Reached',
        content: 'You\'ve reached the maximum number of pets for the free tier. '
                'Upgrade to add more pets and unlock premium features!',
        onUpgrade: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/subscription');
        },
      ),
    );
  }

  Future<void> _togglePetStatus(Pet pet) async {
    try {
      await context.read<PetProvider>().togglePetStatus(
        petId: pet.id,
        isActive: !pet.isActive,
      );
      
      _showSuccessSnackBar(
        pet.isActive ? 'Pet archived' : 'Pet activated',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update pet status: $e');
    }
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      context.read<PetProvider>().searchPets(query);
    });
  }

  void _showFilterOptions() {
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
              leading: const Icon(Icons.pets),
              title: const Text('All Pets'),
              selected: _currentFilter == PetFilter.all,
              onTap: () => _applyFilter(PetFilter.all),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Active Pets'),
              selected: _currentFilter == PetFilter.active,
              onTap: () => _applyFilter(PetFilter.active),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archived Pets'),
              selected: _currentFilter == PetFilter.archived,
              onTap: () => _applyFilter(PetFilter.archived),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilter(PetFilter filter) {
    Navigator.pop(context);
    if (_currentFilter != filter) {
      setState(() => _currentFilter = filter);
      _loadPets();
    }
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
          onPressed: _refreshPets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pets...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter pets',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        tooltip: 'Add new pet',
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: _loadPets,
      );
    }

    return Stack(
      children: [
        Consumer<PetProvider>(
          builder: (context, provider, child) {
            final pets = provider.filteredPets;

            if (pets.isEmpty && !_isLoading) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _refreshPets,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: pets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => PetListItem(
                  pet: pets[index],
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/pet-detail',
                    arguments: pets[index].id,
                  ),
                  onToggleStatus: () => _togglePetStatus(pets[index]),
                  isSubscribed: _isSubscribed,
                ),
              ),
            );
          },
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        message: 'Try adjusting your search or filter settings',
        buttonText: 'Clear Search',
        onAction: () {
          _searchController.clear();
          _onSearchChanged('');
        },
      );
    }

    switch (_currentFilter) {
      case PetFilter.archived:
        return const EmptyState(
          icon: Icons.archive_outlined,
          title: 'No Archived Pets',
          message: 'Archived pets will appear here',
        );
      case PetFilter.active:
      case PetFilter.all:
      default:
        return EmptyState(
          icon: Icons.pets,
          title: 'No Pets Yet',
          message: 'Add your first pet to get started!',
          buttonText: 'Add Pet',
          onAction: _navigateToAddPet,
        );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }
}
