import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/deal.dart';
import '../services/deal_service.dart';

class DealsScreen extends StatefulWidget {
  final String? eventId;

  const DealsScreen({super.key, this.eventId});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  final DealService _service = DealService();
  List<Deal> _deals = [];
  bool _isLoading = true;
  DealCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    setState(() => _isLoading = true);
    try {
      final deals = widget.eventId != null
          ? await _service.getDealsForEvent(widget.eventId!)
          : await _service.getDeals(category: _selectedCategory);
      setState(() {
        _deals = deals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réductions Exclusives'),
        actions: [
          PopupMenuButton<DealCategory?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (category) {
              setState(() => _selectedCategory = category);
              _loadDeals();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Toutes les catégories'),
              ),
              ...DealCategory.values.map((category) {
                return PopupMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category)),
                      const SizedBox(width: 8),
                      Text(_getCategoryLabel(category)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deals.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('Aucune réduction disponible'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _deals.length,
              itemBuilder: (context, index) {
                final deal = _deals[index];
                return _DealCard(
                  deal: deal,
                  eventId: widget.eventId,
                  onClaim: () => _claimDeal(deal.id),
                );
              },
            ),
    );
  }

  Future<void> _claimDeal(String dealId) async {
    if (widget.eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un événement')),
      );
      return;
    }

    try {
      await _service.claimDeal(dealId, widget.eventId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réduction réclamée avec succès !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  IconData _getCategoryIcon(DealCategory category) {
    switch (category) {
      case DealCategory.restaurant:
        return Icons.restaurant;
      case DealCategory.hotel:
        return Icons.hotel;
      case DealCategory.activity:
        return Icons.local_activity;
      case DealCategory.transport:
        return Icons.directions_car;
      case DealCategory.entertainment:
        return Icons.movie;
      case DealCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryLabel(DealCategory category) {
    switch (category) {
      case DealCategory.restaurant:
        return 'Restaurants';
      case DealCategory.hotel:
        return 'Hôtels';
      case DealCategory.activity:
        return 'Activités';
      case DealCategory.transport:
        return 'Transport';
      case DealCategory.entertainment:
        return 'Divertissement';
      case DealCategory.other:
        return 'Autre';
    }
  }
}

class _DealCard extends StatelessWidget {
  final Deal deal;
  final String? eventId;
  final VoidCallback onClaim;

  const _DealCard({required this.deal, this.eventId, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deal.imageUrl != null)
            Stack(
              children: [
                Image.network(
                  deal.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(_getCategoryIcon(deal.category), size: 64),
                    );
                  },
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '-${deal.discountPercentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (deal.logoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          deal.logoUrl!,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                            );
                          },
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal.provider,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            deal.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CategoryBadge(category: deal.category),
                  ],
                ),
                const SizedBox(height: 12),
                Text(deal.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.people, size: 16),
                      label: Text('Min. ${deal.minGroupSize} pers.'),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (deal.location != null)
                      Chip(
                        avatar: const Icon(Icons.location_on, size: 16),
                        label: Text(deal.location!),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (deal.validUntil != null)
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          'Valide jusqu\'au ${_formatDate(deal.validUntil!)}',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if (deal.discountCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Code promo',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                deal.discountCode!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // Copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copié !')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (deal.websiteUrl != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl(deal.websiteUrl!),
                          icon: const Icon(Icons.language),
                          label: const Text('Site web'),
                        ),
                      ),
                    if (deal.websiteUrl != null && deal.bookingUrl != null)
                      const SizedBox(width: 8),
                    if (deal.bookingUrl != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(deal.bookingUrl!),
                          icon: const Icon(Icons.event_available),
                          label: const Text('Réserver'),
                        ),
                      ),
                    if (eventId != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onClaim,
                        icon: const Icon(Icons.bookmark),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(DealCategory category) {
    switch (category) {
      case DealCategory.restaurant:
        return Icons.restaurant;
      case DealCategory.hotel:
        return Icons.hotel;
      case DealCategory.activity:
        return Icons.local_activity;
      case DealCategory.transport:
        return Icons.directions_car;
      case DealCategory.entertainment:
        return Icons.movie;
      case DealCategory.other:
        return Icons.more_horiz;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final DealCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 14, color: _getColor()),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: TextStyle(
              color: _getColor(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (category) {
      case DealCategory.restaurant:
        return Icons.restaurant;
      case DealCategory.hotel:
        return Icons.hotel;
      case DealCategory.activity:
        return Icons.local_activity;
      case DealCategory.transport:
        return Icons.directions_car;
      case DealCategory.entertainment:
        return Icons.movie;
      case DealCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getLabel() {
    switch (category) {
      case DealCategory.restaurant:
        return 'Restaurant';
      case DealCategory.hotel:
        return 'Hôtel';
      case DealCategory.activity:
        return 'Activité';
      case DealCategory.transport:
        return 'Transport';
      case DealCategory.entertainment:
        return 'Divertissement';
      case DealCategory.other:
        return 'Autre';
    }
  }

  Color _getColor() {
    switch (category) {
      case DealCategory.restaurant:
        return Colors.orange;
      case DealCategory.hotel:
        return Colors.purple;
      case DealCategory.activity:
        return Colors.green;
      case DealCategory.transport:
        return Colors.blue;
      case DealCategory.entertainment:
        return Colors.pink;
      case DealCategory.other:
        return Colors.grey;
    }
  }
}
