import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';

abstract class CategoryFirebaseService {
  Future<void> syncCategoriesToCloud(String userId);
  Future<void> syncCategoriesFromCloud(String userId);
  Future<List<CategoryData>> getCategoriesFromCloud(String userId);
  Stream<List<CategoryData>> watchCategoriesFromCloud(String userId);
}

class CategoryFirebaseServiceImpl implements CategoryFirebaseService {
  final FirebaseFirestore _firestore;
  final CategoryDao _categoryDao;
  final firebase_auth.FirebaseAuth _auth;

  CategoryFirebaseServiceImpl(this._firestore, this._categoryDao, this._auth);

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference _getUserCategoriesCollection(String userId) {
    // Verify that the userId matches the authenticated user
    if (_currentUserId != null && _currentUserId != userId) {
      throw Exception(
        'Access denied: userId does not match authenticated user',
      );
    }
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  @override
  Future<void> syncCategoriesToCloud(String userId) async {
    final categories = await _categoryDao.getAllCategories();
    if (categories.isEmpty) return;

    final batch = _firestore.batch();
    final colRef = _getUserCategoriesCollection(userId);

    for (final category in categories) {
      final docRef = colRef.doc(category.id);
      batch.set(docRef, _categoryToMap(category), SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<void> syncCategoriesFromCloud(String userId) async {
    final snapshot = await _getUserCategoriesCollection(userId).get();

    if (snapshot.docs.isEmpty) return;

    final categories = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CategoriesCompanion.insert(
        id: data['id'],
        name: data['name'] as String,
        iconCode: data['iconCode'] as int,
        iconColor: data['iconColor'] as int,
        type: data['type'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
      );
    }).toList();

    for (final category in categories) {
      await _categoryDao.insertCategory(category);
    }
  }

  @override
  Future<List<CategoryData>> getCategoriesFromCloud(String userId) async {
    try {
      final snapshot = await _getUserCategoriesCollection(userId).get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CategoryData(
          id: data['id'] as String,
          name: data['name'] as String,
          iconCode: data['iconCode'] as int,
          iconColor: data['iconColor'] as int,
          type: data['type'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get categories from cloud: $e');
    }
  }

  @override
  Stream<List<CategoryData>> watchCategoriesFromCloud(String userId) {
    return _getUserCategoriesCollection(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CategoryData(
          id: data['id'] as String,
          name: data['name'] as String,
          iconCode: data['iconCode'] as int,
          iconColor: data['iconColor'] as int,
          type: data['type'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _categoryToMap(CategoryData category) {
    return {
      'id': category.id,
      'name': category.name,
      'iconCode': category.iconCode,
      'iconColor': category.iconColor,
      'type': category.type,
      'createdAt': category.createdAt.toIso8601String(),
      'updatedAt': category.updatedAt.toIso8601String(),
    };
  }
}
