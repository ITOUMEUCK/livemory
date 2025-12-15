import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../../domain/entities/budget.dart';

/// Écran de détail d'un budget
class BudgetDetailScreen extends StatelessWidget {
  final String budgetId;

  const BudgetDetailScreen({super.key, required this.budgetId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BudgetProvider, AuthProvider>(
      builder: (context, budgetProvider, authProvider, child) {
        final budget = budgetProvider.getBudgetById(budgetId);

        if (budget == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Budget introuvable')),
            body: const Center(child: Text('Budget introuvable')),
          );
        }

        final userId = authProvider.currentUser?.id ?? 'user_1';
        final userBalance = budget.getUserBalance(userId);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, budget, userBalance),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques générales
                      _buildStatsCards(budget),
                      const SizedBox(height: 24),

                      // Répartition par catégorie
                      Text(
                        'Répartition par catégorie',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryBreakdown(budget),
                      const SizedBox(height: 24),

                      // Soldes des participants
                      Text('Soldes', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      _buildParticipantBalances(budget),
                      const SizedBox(height: 24),

                      // Remboursements nécessaires
                      if (budget.expenses.isNotEmpty) ...[
                        Text(
                          'Remboursements',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildSettlements(budget),
                        const SizedBox(height: 24),
                      ],

                      // Liste des dépenses
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dépenses', style: AppTextStyles.titleMedium),
                          TextButton.icon(
                            onPressed: () =>
                                _showAddExpenseDialog(context, budget),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Ajouter'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildExpensesList(context, budget, userId),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Budget budget, double userBalance) {
    final isOverBudget = budget.isOverBudget;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(budget.name),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isOverBudget ? AppColors.error : AppColors.primary,
                (isOverBudget ? AppColors.error : AppColors.primary).withValues(
                  alpha: 0.7,
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dépensé',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${budget.totalSpent.toStringAsFixed(2)} €',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            userBalance >= 0 ? 'À recevoir' : 'À payer',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${userBalance.abs().toStringAsFixed(2)} €',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(Budget budget) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet,
            label: 'Budget',
            value: '${budget.totalAmount.toStringAsFixed(0)}€',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.receipt,
            label: 'Dépenses',
            value: '${budget.expenses.length}',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            label: 'Participants',
            value: '${budget.participantIds.length}',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Budget budget) {
    if (budget.expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            'Aucune dépense pour le moment',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final categories = budget.expensesByCategory;
    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final percentage = (entry.value / budget.totalSpent * 100);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(entry.key.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key.displayName,
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(2)} €',
                          style: AppTextStyles.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(
                          _getCategoryColor(entry.key),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParticipantBalances(Budget budget) {
    final shares = budget.calculateShares();
    final paid = budget.calculatePaidAmounts();

    return Column(
      children: budget.participantIds.map((userId) {
        final userShare = shares[userId] ?? 0;
        final userPaid = paid[userId] ?? 0;
        final balance = userPaid - userShare;
        final isPositive = balance >= 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPositive
                  ? AppColors.secondary
                  : AppColors.error,
              child: Text(
                userId.substring(userId.length - 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('Utilisateur $userId'),
            subtitle: Text(
              'Part: ${userShare.toStringAsFixed(2)}€ • Payé: ${userPaid.toStringAsFixed(2)}€',
              style: AppTextStyles.bodySmall,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isPositive ? 'À recevoir' : 'À payer',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${balance.abs().toStringAsFixed(2)} €',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isPositive ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettlements(Budget budget) {
    final settlements = budget.calculateSettlements();

    if (settlements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tous les comptes sont équilibrés !',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: settlements.map((settlement) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.arrow_forward, color: AppColors.primary),
            title: Text(
              'Utilisateur ${settlement.from} → Utilisateur ${settlement.to}',
              style: AppTextStyles.bodyMedium,
            ),
            trailing: Text(
              '${settlement.amount.toStringAsFixed(2)} €',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    Budget budget,
    String userId,
  ) {
    if (budget.expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.receipt,
                size: 32,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'Aucune dépense',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedExpenses = List<Expense>.from(budget.expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: sortedExpenses.map((expense) {
        final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
        final userShare = expense.getUserShare(userId);
        final hasUserPaid = expense.hasUserPaid(userId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showExpenseDetails(context, budget, expense),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            expense.category,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          expense.category.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${expense.category.displayName} • ${dateFormat.format(expense.date)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${expense.amount.toStringAsFixed(2)} €',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (userShare > 0)
                            Text(
                              'Votre part: ${userShare.toStringAsFixed(2)}€',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: hasUserPaid
                                    ? AppColors.secondary
                                    : AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (expense.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      expense.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Payé par: Utilisateur ${expense.paidBy}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const Spacer(),
                      if (expense.isFullyPaid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Payé',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${expense.remaining.toStringAsFixed(2)}€ restant',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddExpenseDialog(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => _AddExpenseDialog(budget: budget),
    );
  }

  void _showExpenseDetails(
    BuildContext context,
    Budget budget,
    Expense expense,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          _ExpenseDetailsSheet(budget: budget, expense: expense),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.accommodation:
        return Colors.purple;
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.activities:
        return Colors.green;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _AddExpenseDialog extends StatefulWidget {
  final Budget budget;

  const _AddExpenseDialog({required this.budget});

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;
  String _paidBy = '';

  @override
  void initState() {
    super.initState();
    _paidBy = widget.budget.participantIds.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une dépense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) => v?.isEmpty ?? true ? 'Titre requis' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v ?? '') == null
                    ? 'Montant invalide'
                    : null,
              ),
              DropdownButtonFormField<ExpenseCategory>(
                value: _category,
                items: ExpenseCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.icon} ${c.displayName}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              DropdownButtonFormField<String>(
                value: _paidBy,
                decoration: const InputDecoration(labelText: 'Payé par'),
                items: widget.budget.participantIds
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text('Utilisateur $id'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _paidBy = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(onPressed: _handleAdd, child: const Text('Ajouter')),
      ],
    );
  }

  void _handleAdd() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final perPerson = amount / widget.budget.participantIds.length;
    final shares = widget.budget.participantIds
        .map((id) => ExpenseShare(userId: id, amount: perPerson))
        .toList();

    await context.read<BudgetProvider>().addExpense(
      budgetId: widget.budget.id,
      title: _titleController.text,
      amount: amount,
      category: _category,
      paidBy: _paidBy,
      shares: shares,
    );

    if (mounted) Navigator.pop(context);
  }
}

class _ExpenseDetailsSheet extends StatelessWidget {
  final Budget budget;
  final Expense expense;

  const _ExpenseDetailsSheet({required this.budget, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(expense.title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          Text('Détail des parts:', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          ...expense.shares.map((share) {
            return ListTile(
              leading: Icon(
                share.isPaid ? Icons.check_circle : Icons.pending,
                color: share.isPaid ? AppColors.secondary : AppColors.warning,
              ),
              title: Text('Utilisateur ${share.userId}'),
              trailing: Text('${share.amount.toStringAsFixed(2)} €'),
            );
          }),
        ],
      ),
    );
  }
}
