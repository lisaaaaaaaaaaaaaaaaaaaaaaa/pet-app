// lib/screens/onboarding/pet_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/pet.dart';
import '../../providers/pet_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/onboarding/onboarding_progress.dart';
import '../../widgets/common/animated_page_transition.dart';
import 'pet_basic_info_screen.dart';
import 'pet_health_info_screen.dart';
import 'pet_lifestyle_screen.dart';
import 'subscription_screen.dart';

class PetOnboardingScreen extends StatefulWidget {
  const PetOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<PetOnboardingScreen> createState() => _PetOnboardingScreenState();
}

class _PetOnboardingScreenState extends State<PetOnboardingScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  late Pet _pet;
  late List<OnboardingStep> _steps;

  @override
  void initState() {
    super.initState();
    _initializeOnboarding();
    _setupBackButtonHandling();
  }

  void _initializeOnboarding() {
    _pet = const Pet();
    _steps = [
      OnboardingStep(
        title: 'Basic Information',
        subtitle: "Let's start with the basics",
        screen: PetBasicInfoScreen(
          onNext: _handleBasicInfo,
          onBack: _handleBack,
        ),
      ),
      OnboardingStep(
        title: 'Health Profile',
        subtitle: 'Tell us about your pet\'s health',
        screen: PetHealthInfoScreen(
          onNext: _handleHealthInfo,
          onBack: _handleBack,
        ),
      ),
      OnboardingStep(
        title: 'Lifestyle & Preferences',
        subtitle: 'Help us understand your pet better',
        screen: PetLifestyleScreen(
          onNext: _handleLifestyleInfo,
          onBack: _handleBack,
        ),
      ),
      OnboardingStep(
        title: 'Complete Setup',
        subtitle: 'Choose your plan',
        screen: SubscriptionScreen(
          onComplete: _handleSubscription,
          onBack: _handleBack,
        ),
      ),
    ];
  }

  void _setupBackButtonHandling() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().setCanPop(
        _currentPage > 0,
        onPop: _handleBack,
      );
    });
  }

  Future<void> _handleBasicInfo(Map<String, dynamic> basicInfo) async {
    try {
      setState(() => _isLoading = true);
      await _pet.updateBasicInfo(basicInfo);
      _nextPage();
    } catch (e) {
      _showError('Failed to save basic information');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleHealthInfo(Map<String, dynamic> healthInfo) async {
    try {
      setState(() => _isLoading = true);
      await _pet.updateHealthInfo(healthInfo);
      _nextPage();
    } catch (e) {
      _showError('Failed to save health information');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLifestyleInfo(Map<String, dynamic> lifestyleInfo) async {
    try {
      setState(() => _isLoading = true);
      await _pet.updateLifestyleInfo(lifestyleInfo);
      _nextPage();
    } catch (e) {
      _showError('Failed to save lifestyle information');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubscription(Map<String, dynamic> subscriptionInfo) async {
    try {
      setState(() => _isLoading = true);
      await _savePetData(subscriptionInfo);
      await _completePetSetup();
    } catch (e) {
      _showError('Failed to complete setup');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePetData(Map<String, dynamic> subscriptionInfo) async {
    final petProvider = context.read<PetProvider>();
    await petProvider.addPet(_pet);
    if (subscriptionInfo['isPremium'] == true) {
      await petProvider.upgradeToPremium(_pet.id);
    }
  }
  // ... (continued in next part)
// Continuing lib/screens/onboarding/pet_onboarding_screen.dart

  Future<void> _completePetSetup() async {
    final onboardingProvider = context.read<OnboardingProvider>();
    await onboardingProvider.markOnboardingComplete();
    
    if (!mounted) return;
    
    Navigator.pushReplacementNamed(
      context,
      '/dashboard',
      arguments: {'showWelcome': true},
    );
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
        context.read<OnboardingProvider>().setCanPop(true);
      });
    }
  }

  Future<bool> _handleBack() async {
    if (_currentPage == 0) {
      final shouldExit = await _showExitConfirmation();
      return shouldExit;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage--;
      context.read<OnboardingProvider>().setCanPop(_currentPage > 0);
    });
    return false;
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Setup?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('STAY'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: () => _steps[_currentPage].retry?.call(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(theme),
                  _buildProgress(theme),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _steps.length,
                      itemBuilder: (context, index) => AnimatedPageTransition(
                        child: _steps[index].screen,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                const LoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _steps[_currentPage].title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _steps[_currentPage].subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: OnboardingProgress(
        steps: _steps.length,
        currentStep: _currentPage + 1,
        progressColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final Widget screen;
  final VoidCallback? retry;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.screen,
    this.retry,
  });
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}