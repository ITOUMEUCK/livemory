import '../config/api_config.dart';
import '../models/deal.dart';
import 'api_service.dart';

class DealService {
  final ApiService _apiService = ApiService();

  // Get all deals
  Future<List<Deal>> getDeals({
    DealCategory? category,
    String? location,
    int? minGroupSize,
  }) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConfig.dealsEndpoint,
      queryParameters: {
        if (category != null) 'category': category.toString().split('.').last,
        if (location != null) 'location': location,
        if (minGroupSize != null) 'minGroupSize': minGroupSize,
      },
    );
    final deals = (response['deals'] as List)
        .map((json) => Deal.fromJson(json))
        .toList();
    return deals;
  }

  // Get deal by ID
  Future<Deal> getDealById(String id) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.dealsEndpoint}/$id',
    );
    return Deal.fromJson(response['deal']);
  }

  // Get deals for event location
  Future<List<Deal>> getDealsForEvent(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.dealsEndpoint}/event/$eventId',
    );
    final deals = (response['deals'] as List)
        .map((json) => Deal.fromJson(json))
        .toList();
    return deals;
  }

  // Claim deal
  Future<Map<String, dynamic>> claimDeal(String dealId, String eventId) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.dealsEndpoint}/$dealId/claim',
      data: {'eventId': eventId},
    );
    return response;
  }

  // Get claimed deals for event
  Future<List<Deal>> getClaimedDeals(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/deals',
    );
    final deals = (response['deals'] as List)
        .map((json) => Deal.fromJson(json))
        .toList();
    return deals;
  }
}
