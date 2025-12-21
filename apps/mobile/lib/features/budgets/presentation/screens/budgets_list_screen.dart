import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../providers/budget_provider.dart';
import '../../domain/entities/budget.dart';

/// Écran liste des budgets
class BudgetsListScreen extends StatefulWidget {
  final String? eventId;

  const BudgetsListScreen({super.key, this.eventId});

  @override
  State<BudgetsListScreen> createState() => _BudgetsListScreenState();
}

class _BudgetsListScreenState extends State<BudgetsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().fetchBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId != null ? 'Budgets' : 'Tous les budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BudgetProvider>().fetchBudgets();
            },
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.isLoading && budgetProvider.budgets.isEmpty) {
            return const LoadingIndicator();
          }

          if (budgetProvider.errorMessage != null) {
            return ErrorView(
              message: budgetProvider.errorMessage!,
              onRetry: () => budgetProvider.fetchBudgets(),
            );
          }

          final budgets = widget.eventId != null
              ? budgetProvider.getBudgetsByEvent(widget.eventId!)
              : budgetProvider.budgets;

          if (budgets.isEmpty) {
            return EmptyState(
              title: 'Aucun budget',
              subtitle: widget.eventId != null
                  ? 'Créez un budget pour cet événement'
                  : 'Commencez par créer votre premier budget',
              icon: Icons.account_balance_wallet,
              actionLabel: widget.eventId != null ? 'Créer un budget' : null,
              onAction: widget.eventId != null
                  ? () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.createBudget,
                        arguments: widget.eventId,
                      );
                    }
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () => budgetProvider.fetchBudgets(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Statistiques globales
                if (widget.eventId == null) ...[
                  _buildGlobalStats(budgetProvider),
                  const SizedBox(height: 24),
                ],

                // Liste des budgets
                ...budgets.map(
                  (budget) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _BudgetCard(
                      budget: budget,
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.budgetDetailPath(budget.id));
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgets_create_fab',
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.createBudget, arguments: widget.eventId);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau budget'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildGlobalStats(BudgetProvider provider) {
    final stats = provider.getGlobalStats();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vue d\'ensemble',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                icon: Icons.wallet,
                label: 'Budgets',
                value: '${stats['totalBudgets']}',
              ),
              _StatItem(
                icon: Icons.trending_up,
                label: 'Dépensé',
                value: '${stats['totalSpent'].toStringAsFixed(0)}€',
              ),
              _StatItem(
                icon: Icons.warning,
                label: 'Dépassés',
                value: '${stats['overBudgetCount']}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher un item de statistique
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

/// Carte d'affichage d'un budget
class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;

  const _BudgetCard({required this.budget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final percentageSpent = budget.percentageSpent;
    final isOverBudget = budget.isOverBudget;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de progression en haut
            LinearProgressIndicator(
              value: (percentageSpent / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(
                isOverBudget ? AppColors.error : AppColors.secondary,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec nom et type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.name,
                              style: AppTextStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  budget.splitType.icon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  budget.splitType.displayName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${budget.participantIds.length} participant${budget.participantIds.length > 1 ? 's' : ''}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isOverBudget)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning,
                                size: 14,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Dépassé',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Montants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dépensé',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${budget.totalSpent.toStringAsFixed(2)} €',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: isOverBudget
                                  ? AppColors.error
                                  : AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Budget total',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${budget.totalAmount.toStringAsFixed(2)} €',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Barre de détail avec pourcentage
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (percentageSpent / 100).clamp(
                              0.0,
                              1.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isOverBudget
                                    ? AppColors.error
                                    : AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${percentageSpent.toStringAsFixed(0)}%',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isOverBudget
                              ? AppColors.error
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Informations supplémentaires
                  Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${budget.expenses.length} dépense${budget.expenses.length > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        isOverBudget ? Icons.trending_down : Icons.trending_up,
                        size: 16,
                        color: isOverBudget
                            ? AppColors.error
                            : AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverBudget
                            ? '+${(budget.totalSpent - budget.totalAmount).toStringAsFixed(0)}€'
                            : '${budget.remaining.toStringAsFixed(0)}€ restant',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isOverBudget
                              ? AppColors.error
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
