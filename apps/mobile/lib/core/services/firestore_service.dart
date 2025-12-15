import 'package:cloud_firestore/cloud_firestore.dart';

/// Service Firestore pour les opérations CRUD
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== COLLECTIONS ====================

  CollectionReference get users => _firestore.collection('users');
  CollectionReference get groups => _firestore.collection('groups');
  CollectionReference get events => _firestore.collection('events');
  CollectionReference get polls => _firestore.collection('polls');
  CollectionReference get budgets => _firestore.collection('budgets');
  CollectionReference get notifications =>
      _firestore.collection('notifications');

  // ==================== CRUD GÉNÉRIQUE ====================

  /// Créer un document
  Future<String> create(String collection, Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection(collection).add(data);
    return docRef.id;
  }

  /// Créer un document avec un ID spécifique
  Future<void> createWithId(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection(collection).doc(id).set(data);
  }

  /// Lire un document
  Future<DocumentSnapshot> read(String collection, String id) async {
    return await _firestore.collection(collection).doc(id).get();
  }

  /// Mettre à jour un document
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(collection).doc(id).update(data);
  }

  /// Supprimer un document
  Future<void> delete(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  /// Lire tous les documents d'une collection
  Future<QuerySnapshot> readAll(String collection) async {
    return await _firestore.collection(collection).get();
  }

  /// Lire avec une requête
  Future<QuerySnapshot> query(
    String collection, {
    String? field,
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic isLessThan,
    List<dynamic>? whereIn,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    Query query = _firestore.collection(collection);

    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (whereIn != null) {
        query = query.where(field, whereIn: whereIn);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }

  /// Stream d'un document
  Stream<DocumentSnapshot> streamDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  /// Stream d'une collection
  Stream<QuerySnapshot> streamCollection(
    String collection, {
    String? field,
    dynamic isEqualTo,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (field != null && isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  // ==================== REQUÊTES SPÉCIFIQUES ====================

  /// Récupérer les groupes d'un utilisateur
  Future<QuerySnapshot> getUserGroups(String userId) async {
    return await query('groups', field: 'memberIds', whereIn: [userId]);
  }

  /// Récupérer les événements d'un groupe
  Future<QuerySnapshot> getGroupEvents(String groupId) async {
    return await query(
      'events',
      field: 'groupId',
      isEqualTo: groupId,
      orderBy: 'startDate',
      descending: false,
    );
  }

  /// Récupérer les sondages d'un événement
  Future<QuerySnapshot> getEventPolls(String eventId) async {
    return await query(
      'polls',
      field: 'eventId',
      isEqualTo: eventId,
      orderBy: 'createdAt',
      descending: true,
    );
  }

  /// Récupérer les budgets d'un événement
  Future<QuerySnapshot> getEventBudgets(String eventId) async {
    return await query(
      'budgets',
      field: 'eventId',
      isEqualTo: eventId,
      orderBy: 'createdAt',
      descending: true,
    );
  }

  /// Récupérer les notifications d'un utilisateur
  Future<QuerySnapshot> getUserNotifications(String userId) async {
    return await query(
      'notifications',
      field: 'userId',
      isEqualTo: userId,
      orderBy: 'createdAt',
      descending: true,
      limit: 50,
    );
  }

  /// Stream des notifications d'un utilisateur
  Stream<QuerySnapshot> streamUserNotifications(String userId) {
    return streamCollection(
      'notifications',
      field: 'userId',
      isEqualTo: userId,
      orderBy: 'createdAt',
      descending: true,
      limit: 50,
    );
  }

  // ==================== BATCH OPERATIONS ====================

  /// Opérations batch (pour plusieurs écritures)
  WriteBatch batch() => _firestore.batch();

  /// Transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    return await _firestore.runTransaction(updateFunction);
  }
}
