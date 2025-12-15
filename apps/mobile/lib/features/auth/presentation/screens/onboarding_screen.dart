import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/buttons/buttons.dart';

/// Onboarding screen avec 3 slides explicatives
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.groups,
      iconColor: AppColors.primary,
      title: 'Organise tes moments',
      description:
          'Crée des groupes et planifie facilement tes week-ends et soirées entre amis en quelques taps',
    ),
    OnboardingPage(
      icon: Icons.event_available,
      iconColor: AppColors.secondary,
      title: 'Décide ensemble',
      description:
          'Vote sur les dates, lieux et activités. Fini les discussions interminables en messagerie !',
    ),
    OnboardingPage(
      icon: Icons.account_balance_wallet,
      iconColor: AppColors.primary,
      title: 'Gère les budgets',
      description:
          'Partage les frais facilement et garde une trace claire de qui doit combien à qui',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    // TODO: Sauvegarder dans SharedPreferences que l'onboarding a été vu
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Passer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // PageView avec les slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Indicateurs de page
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Bouton suivant/commencer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: _currentPage == _pages.length - 1
                    ? 'Commencer'
                    : 'Suivant',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 80, color: page.iconColor),
          ),
          const SizedBox(height: 48),

          // Titre
          Text(
            page.title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.textTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Modèle pour une page d'onboarding
class OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
