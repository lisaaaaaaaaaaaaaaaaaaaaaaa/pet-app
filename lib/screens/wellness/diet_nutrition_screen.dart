import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pet_provider.dart';
import '../../services/diet_service.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../models/meal.dart';
import '../../models/food_item.dart';
import '../../models/diet_record.dart';
import '../../models/nutrition_goal.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/error_dialog.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/diet_tracker_card.dart';
import '../../widgets/health_stats_card.dart';
import '../../widgets/health_summary_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/weight_chart.dart';
import '../../widgets/dialogs/add_meal_dialog.dart';
import '../../widgets/dialogs/add_food_dialog.dart';

class DietNutritionScreen extends StatefulWidget {
  const DietNutritionScreen({Key? key}) : super(key: key);

  @override
  State<DietNutritionScreen> createState() => _DietNutritionScreenState();
}

class _DietNutritionScreenState extends State<DietNutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late DietService _dietService;
  late AnalyticsService _analyticsService;
  late NotificationService _notificationService;
  late String _selectedPetId;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isAnalyticsLoading = false;
  List<FoodItem> _foodItems = [];
  List<DietRecord> _dietRecords = [];
  NutritionGoal? _nutritionGoal;
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _setupServices();
    _initializeData();
    _setupNotifications();
    _setupTabListener();
  }

  void _setupServices() {
    _dietService = context.read<DietService>();
    _analyticsService = context.read<AnalyticsService>();
    _notificationService = context.read<NotificationService>();
  }

  void _setupTabListener() {
    _tabController.addListener(() {
      if (_tabController.index == 3 && !_isAnalyticsLoading) {
        _loadAnalytics();
      }
    });
  }

  Future<void> _setupNotifications() async {
    await _notificationService.scheduleMealReminders(
      petId: _selectedPetId,
      mealTimes: await _dietService.getMealSchedule(_selectedPetId),
    );
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final petProvider = context.read<PetProvider>();
      _selectedPetId = petProvider.selectedPet!.id;

      await Future.wait([
        _loadDietData(),
        _loadFoodItems(),
        _loadNutritionGoals(),
      ]);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            message: 'Error loading diet data: $e',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDietData() async {
    try {
      _dietRecords = await _dietService.getDietRecords(
        _selectedPetId,
        _selectedDate.subtract(const Duration(days: 30)),
        _selectedDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadFoodItems() async {
    try {
      _foodItems = await _dietService.getFoodItems(_selectedPetId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadNutritionGoals() async {
    try {
      _nutritionGoal = await _dietService.getNutritionGoal(_selectedPetId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isAnalyticsLoading = true);
    try {
      _analyticsData = await _analyticsService.getDietAnalytics(
        petId: _selectedPetId,
        startDate: _selectedDate.subtract(const Duration(days: 30)),
        endDate: _selectedDate,
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            message: 'Error loading analytics: $e',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyticsLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().selectedPet;
    if (pet == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Diet & Nutrition',
        subtitle: pet.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _showReminderSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Meals'),
            Tab(text: 'Foods'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildMealsTab(),
                _buildFoodDatabaseTab(),
                _buildAnalyticsTab(),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HealthSummaryCard(
          title: 'Today\'s Diet Summary',
          petId: _selectedPetId,
          date: _selectedDate,
          nutritionGoal: _nutritionGoal,
        ),
        const SizedBox(height: 16),
        DietTrackerCard(
          petId: _selectedPetId,
          date: _selectedDate,
          onAddMeal: _showAddMealDialog,
          onEditMeal: _showEditMealDialog,
        ),
        const SizedBox(height: 16),
        QuickActionCard(
          title: 'Quick Actions',
          actions: [
            QuickAction(
              icon: Icons.add_circle_outline,
              label: 'Log Meal',
              onTap: _showAddMealDialog,
            ),
            QuickAction(
              icon: Icons.food_bank_outlined,
              label: 'Add Food',
              onTap: _showAddFoodDialog,
            ),
            QuickAction(
              icon: Icons.schedule,
              label: 'Set Schedule',
              onTap: _showMealScheduleDialog,
            ),
            QuickAction(
              icon: Icons.assessment_outlined,
              label: 'Set Goals',
              onTap: _showNutritionGoalsDialog,
            ),
          ],
        ),
        if (_dietRecords.isNotEmpty) ...[
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Recent Trends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: WeightChart(
                    petId: _selectedPetId,
                    startDate: _selectedDate.subtract(const Duration(days: 7)),
                    endDate: _selectedDate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMealsTab() {
    final todaysMeals = _dietRecords.where(
      (record) => DateUtils.isSameDay(record.timestamp, _selectedDate),
    ).toList();

    if (todaysMeals.isEmpty) {
      return EmptyState(
        icon: Icons.restaurant_menu,
        title: 'No meals logged',
        subtitle: 'Start tracking your pet\'s meals',
        buttonText: 'Add First Meal',
        onButtonPressed: _showAddMealDialog,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todaysMeals.length,
      itemBuilder: (context, index) => _buildMealCard(todaysMeals[index]),
    );
  }

  Widget _buildMealCard(DietRecord record) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(record.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) => _confirmDelete(record),
        onDismissed: (_) => _deleteMealRecord(record),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              _getMealTypeIcon(record.mealType),
              color: AppTheme.primaryColor,
            ),
          ),
          title: Text(record.mealName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('h:mm a').format(record.timestamp)),
              Text('${record.amount} ${record.unit}'),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.calories.round()} kcal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${record.protein?.round() ?? 0}g protein',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          onTap: () => _showDietRecordDetails(record),
        ),
      ),
    );
  }

  Widget _buildFoodDatabaseTab() {
    if (_foodItems.isEmpty) {
      return EmptyState(
        icon: Icons.food_bank,
        title: 'Food database empty',
        subtitle: 'Add your pet\'s favorite foods',
        buttonText: 'Add First Food',
        onButtonPressed: _showAddFoodDialog,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _foodItems.length,
      itemBuilder: (context, index) => _buildFoodItemCard(_foodItems[index]),
    );
  }

  Widget _buildFoodItemCard(FoodItem food) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            _getFoodTypeIcon(food.type),
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(food.name),
        subtitle: Text(
          '${food.calories} kcal per ${food.servingSize} ${food.unit}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _quickAddMeal(food),
              tooltip: 'Quick add meal',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editFoodItem(food),
              tooltip: 'Edit food',
            ),
          ],
        ),
        onTap: () => _showFoodDetails(food),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_isAnalyticsLoading) {
      return const Center(child: LoadingIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HealthStatsCard(
          title: 'Nutrition Statistics',
          petId: _selectedPetId,
          startDate: _selectedDate.subtract(const Duration(days: 30)),
          endDate: _selectedDate,
          data: _analyticsData,
        ),
        const SizedBox(height: 16),
        _buildNutrientDistributionCard(),
        const SizedBox(height: 16),
        _buildMealPatternCard(),
        const SizedBox(height: 16),
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildNutrientDistributionCard() {
    // Implementation for nutrient distribution visualization
    return const CustomCard(
      child: Placeholder(fallbackHeight: 200),
    );
  }

  Widget _buildMealPatternCard() {
    // Implementation for meal pattern analysis
    return const CustomCard(
      child: Placeholder(fallbackHeight: 200),
    );
  }

  Widget _buildRecommendationsCard() {
    // Implementation for AI-powered recommendations
    return const CustomCard(
      child: Placeholder(fallbackHeight: 200),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_tabController.index == 2) { // Food Database tab
      return CustomButton.floating(
        onPressed: _showAddFoodDialog,
        icon: Icons.add,
        label: 'Add Food',
      );
    }

    return CustomButton.floating(
      onPressed: _showAddMealDialog,
      icon: Icons.add,
      label: 'Add Meal',
     );
  }

  IconData _getMealTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_twilight;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  IconData _getFoodTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dry food':
        return Icons.cookie;
      case 'wet food':
        return Icons.soup_kitchen;
      case 'treats':
        return Icons.cake;
      case 'supplement':
        return Icons.medication;
      default:
        return Icons.food_bank;
    }
  }

  Future<void> _showAddMealDialog() async {
    final result = await showDialog<Meal>(
      context: context,
      builder: (context) => AddMealDialog(
        petId: _selectedPetId,
        date: _selectedDate,
        foodItems: _foodItems,
      ),
    );

    if (result != null) {
      await _saveMeal(result);
    }
  }

  Future<void> _showEditMealDialog(DietRecord record) async {
    final result = await showDialog<Meal>(
      context: context,
      builder: (context) => AddMealDialog(
        petId: _selectedPetId,
        date: _selectedDate,
        foodItems: _foodItems,
        existingRecord: record,
      ),
    );

    if (result != null) {
      await _updateMeal(result);
    }
  }

  Future<void> _showAddFoodDialog() async {
    final result = await showDialog<FoodItem>(
      context: context,
      builder: (context) => AddFoodDialog(
        petId: _selectedPetId,
      ),
    );

    if (result != null) {
      await _saveFoodItem(result);
    }
  }

  Future<void> _editFoodItem(FoodItem food) async {
    final result = await showDialog<FoodItem>(
      context: context,
      builder: (context) => AddFoodDialog(
        petId: _selectedPetId,
        foodItem: food,
      ),
    );

    if (result != null) {
      await _updateFoodItem(result);
    }
  }

  Future<void> _showFoodDetails(FoodItem food) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => FoodDetailsSheet(
        food: food,
        onEdit: () => _editFoodItem(food),
        onDelete: () => _deleteFoodItem(food),
        onQuickAdd: () => _quickAddMeal(food),
      ),
    );
  }

  Future<void> _showMealScheduleDialog() async {
    final schedule = await _dietService.getMealSchedule(_selectedPetId);
    final result = await showDialog<List<TimeOfDay>>(
      context: context,
      builder: (context) => MealScheduleDialog(
        currentSchedule: schedule,
      ),
    );

    if (result != null) {
      await _saveMealSchedule(result);
    }
  }

  Future<void> _showNutritionGoalsDialog() async {
    final result = await showDialog<NutritionGoal>(
      context: context,
      builder: (context) => NutritionGoalsDialog(
        currentGoal: _nutritionGoal,
        petId: _selectedPetId,
      ),
    );

    if (result != null) {
      await _saveNutritionGoals(result);
    }
  }

  Future<void> _showReminderSettings() async {
    final schedule = await _dietService.getMealSchedule(_selectedPetId);
    await showDialog(
      context: context,
      builder: (context) => ReminderSettingsDialog(
        schedule: schedule,
        onSave: _updateReminders,
      ),
    );
  }

  Future<void> _saveMeal(Meal meal) async {
    setState(() => _isLoading = true);
    try {
      await _dietService.addMeal(meal);
      await _loadDietData();
      await _updateAnalytics();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal saved successfully')),
      );
    } catch (e) {
      _showErrorDialog('Error saving meal', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMeal(Meal meal) async {
    setState(() => _isLoading = true);
    try {
      await _dietService.updateMeal(meal);
      await _loadDietData();
      await _updateAnalytics();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal updated successfully')),
      );
    } catch (e) {
      _showErrorDialog('Error updating meal', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFoodItem(FoodItem food) async {
    setState(() => _isLoading = true);
    try {
      await _dietService.addFoodItem(food);
      await _loadFoodItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item saved successfully')),
      );
    } catch (e) {
      _showErrorDialog('Error saving food item', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateFoodItem(FoodItem food) async {
    setState(() => _isLoading = true);
    try {
      await _dietService.updateFoodItem(food);
      await _loadFoodItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item updated successfully')),
      );
    } catch (e) {
      _showErrorDialog('Error updating food item', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _quickAddMeal(FoodItem food) async {
    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: _selectedPetId,
      foodItemId: food.id,
      type: 'Snack',
      amount: food.servingSize,
      unit: food.unit,
      calories: food.calories,
      time: DateTime.now(),
      notes: '',
    );

    await _saveMeal(meal);
  }

  Future<void> _saveMealSchedule(List<TimeOfDay> schedule) async {
    setState(() => _isLoading = true);
    try {
      await _dietService.updateMealSchedule(_selectedPetId, schedule);
      await _setupNotifications();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal schedule updated')),
      );
    } catch (e) {
      _showErrorDialog('Error updating schedule', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNutritionGoals(NutritionGoal goals) async {
    setState(() => _isLoading = true);
    try {
      await _dietService.updateNutritionGoals(_selectedPetId, goals);
      await _loadNutritionGoals();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nutrition goals updated')),
      );
    } catch (e) {
      _showErrorDialog('Error updating goals', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateReminders(List<TimeOfDay> schedule) async {
    try {
      await _notificationService.updateMealReminders(
        petId: _selectedPetId,
        mealTimes: schedule,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminders updated')),
      );
    } catch (e) {
      _showErrorDialog('Error updating reminders', e);
    }
  }

  Future<bool> _confirmDelete(DietRecord record) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteMealRecord(DietRecord record) async {
    try {
      await _dietService.deleteMealRecord(record.id);
      await _loadDietData();
      await _updateAnalytics();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _saveMeal(record.toMeal()),
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error deleting meal', e);
    }
  }

  Future<void> _deleteFoodItem(FoodItem food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Item'),
        content: const Text('Are you sure you want to delete this food item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dietService.deleteFoodItem(food.id);
        await _loadFoodItems();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food item deleted')),
        );
      } catch (e) {
        _showErrorDialog('Error deleting food item', e);
      }
    }
  }

  Future<void> _updateAnalytics() async {
    if (_tabController.index == 3) {
      await _loadAnalytics();
    }
  }

  void _showErrorDialog(String title, dynamic error) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: error.toString(),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadDietData();
      await _updateAnalytics();
    }
  }
} 