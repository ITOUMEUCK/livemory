import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/services/firestore_service.dart';
import 'package:mobile/features/polls/domain/entities/poll.dart';

class PollProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Poll> _polls = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Poll> get polls => _polls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupère tous les sondages
  Future<void> fetchPolls() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestoreService.readAll('polls');
      _polls = querySnapshot.docs
          .map((doc) => _pollFromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des sondages: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Crée un nouveau sondage
  Future<Poll?> createPoll({
    required String question,
    required List<String> optionTexts,
    String? description,
    required String eventId,
    required String creatorId,
    required PollType type,
    DateTime? deadline,
    bool allowMultipleChoices = false,
    bool isAnonymous = false,
  }) async {
    try {
      final now = DateTime.now();
      
      // Générer les options avec des IDs uniques
      final options = optionTexts.asMap().entries.map((entry) {
        return PollOption(
          id: 'option_${now.millisecondsSinceEpoch}_${entry.key}',
          text: entry.value,
          voterIds: [],
        );
      }).toList();

      final pollData = {
        'question': question,
        'description': description,
        'eventId': eventId,
        'creatorId': creatorId,
        'type': _typeToString(type),
        'options': options.map((opt) => _optionToMap(opt)).toList(),
        'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
        'allowMultipleChoices': allowMultipleChoices,
        'isAnonymous': isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final pollId = await _firestoreService.create('polls', pollData);
      
      // Récupérer le document créé pour obtenir l'ID et les timestamps
      final docSnapshot = await _firestoreService.read('polls', pollId);
      final newPoll = _pollFromFirestore(docSnapshot);
      
      _polls.add(newPoll);
      notifyListeners();
      
      return newPoll;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création du sondage: $e';
      notifyListeners();
      debugPrint(_errorMessage);
      return null;
    }
  }

  /// Vote pour une ou plusieurs options
  Future<void> vote(String pollId, String userId, List<String> optionIds) async {
    try {
      final pollIndex = _polls.indexWhere((p) => p.id == pollId);
      if (pollIndex == -1) return;

      final poll = _polls[pollIndex];
      final updatedOptions = List<PollOption>.from(poll.options);

      // Si le sondage n'autorise qu'un seul choix, retirer les votes précédents
      if (!poll.allowMultipleChoices) {
        for (var i = 0; i < updatedOptions.length; i++) {
          updatedOptions[i] = PollOption(
            id: updatedOptions[i].id,
            text: updatedOptions[i].text,
            voterIds: updatedOptions[i].voterIds.where((id) => id != userId).toList(),
            metadata: updatedOptions[i].metadata,
          );
        }
      }

      // Ajouter les nouveaux votes
      for (var optionId in optionIds) {
        final optionIndex = updatedOptions.indexWhere((opt) => opt.id == optionId);
        if (optionIndex != -1) {
          final option = updatedOptions[optionIndex];
          if (!option.voterIds.contains(userId)) {
            updatedOptions[optionIndex] = PollOption(
              id: option.id,
              text: option.text,
              voterIds: [...option.voterIds, userId],
              metadata: option.metadata,
            );
          }
        }
      }

      // Mettre à jour dans Firestore
      await _firestoreService.update('polls', pollId, {
        'options': updatedOptions.map((opt) => _optionToMap(opt)).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour localement
      _polls[pollIndex] = Poll(
        id: poll.id,
        question: poll.question,
        description: poll.description,
        eventId: poll.eventId,
        creatorId: poll.creatorId,
        type: poll.type,
        options: updatedOptions,
        deadline: poll.deadline,
        allowMultipleChoices: poll.allowMultipleChoices,
        isAnonymous: poll.isAnonymous,
        createdAt: poll.createdAt,
      );
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du vote: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Retire le vote d'un utilisateur
  Future<void> removeVote(String pollId, String userId) async {
    try {
      final pollIndex = _polls.indexWhere((p) => p.id == pollId);
      if (pollIndex == -1) return;

      final poll = _polls[pollIndex];
      final updatedOptions = poll.options.map((option) {
        return PollOption(
          id: option.id,
          text: option.text,
          voterIds: option.voterIds.where((id) => id != userId).toList(),
          metadata: option.metadata,
        );
      }).toList();

      // Mettre à jour dans Firestore
      await _firestoreService.update('polls', pollId, {
        'options': updatedOptions.map((opt) => _optionToMap(opt)).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour localement
      _polls[pollIndex] = Poll(
        id: poll.id,
        question: poll.question,
        description: poll.description,
        eventId: poll.eventId,
        creatorId: poll.creatorId,
        type: poll.type,
        options: updatedOptions,
        deadline: poll.deadline,
        allowMultipleChoices: poll.allowMultipleChoices,
        isAnonymous: poll.isAnonymous,
        createdAt: poll.createdAt,
      );
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du retrait du vote: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Supprime un sondage
  Future<bool> deletePoll(String pollId) async {
    try {
      await _firestoreService.delete('polls', pollId);
      _polls.removeWhere((poll) => poll.id == pollId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du sondage: $e';
      notifyListeners();
      debugPrint(_errorMessage);
      return false;
    }
  }

  /// Récupère les sondages d'un événement spécifique
  List<Poll> getPollsByEvent(String eventId) {
    return _polls.where((poll) => poll.eventId == eventId).toList();
  }

  /// Récupère les sondages actifs (non clôturés)
  List<Poll> get activePolls {
    return _polls.where((poll) => !poll.isClosed).toList();
  }

  /// Récupère les sondages clôturés
  List<Poll> get closedPolls {
    return _polls.where((poll) => poll.isClosed).toList();
  }

  // Méthodes de conversion Firestore

  Poll _pollFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final optionsData = data['options'] as List<dynamic>? ?? [];
    final options = optionsData
        .map((optData) => _optionFromMap(optData as Map<String, dynamic>))
        .toList();

    return Poll(
      id: doc.id,
      question: data['question'] as String,
      description: data['description'] as String?,
      eventId: data['eventId'] as String,
      creatorId: data['creatorId'] as String,
      type: _typeFromString(data['type'] as String),
      options: options,
      deadline: data['deadline'] != null 
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      allowMultipleChoices: data['allowMultipleChoices'] as bool? ?? false,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _optionToMap(PollOption option) {
    return {
      'id': option.id,
      'text': option.text,
      'voterIds': option.voterIds,
      'metadata': option.metadata,
    };
  }

  PollOption _optionFromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'] as String,
      text: map['text'] as String,
      voterIds: List<String>.from(map['voterIds'] as List? ?? []),
      metadata: map['metadata'] as String?,
    );
  }

  String _typeToString(PollType type) {
    return type.toString().split('.').last;
  }

  PollType _typeFromString(String typeStr) {
    switch (typeStr) {
      case 'date':
        return PollType.date;
      case 'location':
        return PollType.location;
      case 'activity':
        return PollType.activity;
      case 'general':
      default:
        return PollType.general;
    }
  }
}
