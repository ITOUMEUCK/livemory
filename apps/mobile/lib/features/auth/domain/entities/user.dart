import 'package:equatable/equatable.dart';

/// Entité User - Représente un utilisateur de l'application
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.role = UserRole.user,
  });

  /// Créer une copie avec modifications
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
    );
  }

  /// Obtenir les initiales du nom (pour avatar)
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  /// Prénom uniquement
  String get firstName {
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts[0] : name;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    phoneNumber,
    createdAt,
    lastLoginAt,
    isEmailVerified,
    role,
  ];

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}

/// Rôles utilisateur
enum UserRole { user, admin, moderator }
