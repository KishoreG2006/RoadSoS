import 'package:isar/isar.dart';

part 'session_model.g.dart';

@collection
class SessionModel {
  Id isarId = 1; // Single session record in local storage

  late String userId;
  late String authToken;
  late bool isLoggedIn;
  late DateTime lastLoginTime;
  late DateTime lastSyncTime;

  SessionModel();

  SessionModel.create({
    required this.userId,
    required this.authToken,
    required this.isLoggedIn,
    required this.lastLoginTime,
    required this.lastSyncTime,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel.create(
      userId: json['userId'] ?? '',
      authToken: json['authToken'] ?? '',
      isLoggedIn: json['isLoggedIn'] ?? false,
      lastLoginTime: json['lastLoginTime'] != null
          ? DateTime.parse(json['lastLoginTime'])
          : DateTime.now(),
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'authToken': authToken,
      'isLoggedIn': isLoggedIn,
      'lastLoginTime': lastLoginTime.toIso8601String(),
      'lastSyncTime': lastSyncTime.toIso8601String(),
    };
  }

  SessionModel copyWith({
    String? userId,
    String? authToken,
    bool? isLoggedIn,
    DateTime? lastLoginTime,
    DateTime? lastSyncTime,
  }) {
    return SessionModel.create(
      userId: userId ?? this.userId,
      authToken: authToken ?? this.authToken,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}
