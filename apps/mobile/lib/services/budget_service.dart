import '../config/api_config.dart';
import '../models/budget.dart';
import 'api_service.dart';

class BudgetService {
  final ApiService _apiService = ApiService();

  // Get budget for an event
  Future<Budget> getEventBudget(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget',
    );
    return Budget.fromJson(response['budget']);
  }

  // Create or update budget
  Future<Budget> updateBudget(String eventId, double totalBudget) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget',
      data: {'totalBudget': totalBudget},
    );
    return Budget.fromJson(response['budget']);
  }

  // Add expense
  Future<Expense> addExpense(String eventId, Expense expense) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget/expenses',
      data: expense.toJson(),
    );
    return Expense.fromJson(response['expense']);
  }

  // Update expense
  Future<Expense> updateExpense(
    String eventId,
    String expenseId,
    Expense expense,
  ) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget/expenses/$expenseId',
      data: expense.toJson(),
    );
    return Expense.fromJson(response['expense']);
  }

  // Delete expense
  Future<void> deleteExpense(String eventId, String expenseId) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget/expenses/$expenseId',
    );
  }

  // Upload receipt
  Future<String> uploadReceipt(
    String eventId,
    String expenseId,
    String filePath,
  ) async {
    final response = await _apiService.uploadFile<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget/expenses/$expenseId/receipt',
      filePath,
      fileKey: 'receipt',
    );
    return response['receiptUrl'];
  }

  // Create payment
  Future<Payment> createPayment(String eventId, Payment payment) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget/payments',
      data: payment.toJson(),
    );
    return Payment.fromJson(response['payment']);
  }

  // Update payment status
  Future<Payment> updatePaymentStatus(
    String eventId,
    String paymentId,
    PaymentStatus status,
  ) async {
    final response = await _apiService.patch<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget/payments/$paymentId',
      data: {'status': status.toString().split('.').last},
    );
    return Payment.fromJson(response['payment']);
  }

  // Get balance summary
  Future<Map<String, dynamic>> getBalanceSummary(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/budget/balance',
    );
    return response;
  }
}
