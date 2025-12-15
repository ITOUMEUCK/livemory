import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetTab extends StatefulWidget {
  final String eventId;

  const BudgetTab({super.key, required this.eventId});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  final BudgetService _service = BudgetService();
  Budget? _budget;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);
    try {
      final budget = await _service.getEventBudget(widget.eventId);
      setState(() {
        _budget = budget;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_budget == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('Aucun budget défini'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showSetBudgetDialog,
              icon: const Icon(Icons.add),
              label: const Text('Définir un budget'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBudget,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBudgetSummary(_budget!),
          const SizedBox(height: 24),
          _buildBudgetChart(_budget!),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddExpenseDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une dépense'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showPaymentsDialog,
                  icon: const Icon(Icons.payment),
                  label: const Text('Paiements'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Dépenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._budget!.expenses.map(
            (expense) => _ExpenseCard(
              expense: expense,
              onDelete: () => _deleteExpense(expense.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(Budget budget) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Budget total', style: TextStyle(fontSize: 16)),
                Text(
                  '${budget.totalBudget.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dépensé'),
                Text(
                  '${budget.spentAmount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: budget.percentageSpent > 90
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Restant'),
                Text(
                  '${budget.remainingBudget.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: budget.remainingBudget < 0
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: budget.percentageSpent / 100,
              backgroundColor: Colors.grey[300],
              color: budget.percentageSpent > 90 ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 4),
            Text(
              '${budget.percentageSpent.toStringAsFixed(1)}% utilisé',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetChart(Budget budget) {
    if (budget.expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final categoryTotals = <String, double>{};
    for (final expense in budget.expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Répartition par catégorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title:
                          '${(entry.value / budget.spentAmount * 100).toStringAsFixed(0)}%',
                      color: _getCategoryColor(entry.key),
                      radius: 50,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryTotals.entries.map((entry) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: _getCategoryColor(entry.key),
                  ),
                  label: Text(
                    '${_getCategoryLabel(entry.key)}: ${entry.value.toStringAsFixed(2)} €',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'transport':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'accommodation':
        return Colors.purple;
      case 'activity':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'transport':
        return 'Transport';
      case 'food':
        return 'Nourriture';
      case 'accommodation':
        return 'Hébergement';
      case 'activity':
        return 'Activités';
      default:
        return 'Autre';
    }
  }

  void _showSetBudgetDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Définir le budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Montant total (€)',
            prefixIcon: Icon(Icons.euro),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Set budget
              Navigator.pop(context);
            },
            child: const Text('Définir'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    // TODO: Show add expense dialog
  }

  void _showPaymentsDialog() {
    // TODO: Show payments dialog
  }

  Future<void> _deleteExpense(String expenseId) async {
    try {
      await _service.deleteExpense(widget.eventId, expenseId);
      _loadBudget();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _ExpenseCard({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category),
          child: Icon(_getCategoryIcon(expense.category), color: Colors.white),
        ),
        title: Text(expense.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.description),
            const SizedBox(height: 4),
            Text('Payé par ${expense.paidByName}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${expense.amount.toStringAsFixed(2)} €',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'transport':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'accommodation':
        return Colors.purple;
      case 'activity':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'transport':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'accommodation':
        return Icons.hotel;
      case 'activity':
        return Icons.local_activity;
      default:
        return Icons.receipt;
    }
  }
}
