import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id isarId = FastHash.hash('user_profile_single'); // Constant ID for local user profile storage

  @Index(unique: true, replace: true)
  late String id;

  late String email;
  late String fullName;
  late String phone;
  late String role; // 'user' or 'admin'
  late DateTime updatedAt;

  UserModel();

  UserModel.create({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.role = 'user',
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.create(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    DateTime? updatedAt,
  }) {
    return UserModel.create(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// FNV-1a 64bit hash algorithm for Isar ID generation
class FastHash {
  static int hash(String str) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < str.length) {
      final codeUnit = str.codeUnitAt(i++);
      hash ^= codeUnit;
      hash *= 0x100000001b3;
    }
    return hash & 0x7fffffffffffffff;
  }
}
