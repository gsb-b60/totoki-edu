class User {
  final String id;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? email;
  final String? phoneNumber;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.createdAt,
    this.avatarUrl,
    this.email,
    this.phoneNumber,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
      'email': email,
      'phone_number': phoneNumber,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      avatarUrl: map['avatar_url'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phone_number'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    String? avatarUrl,
    String? email,
    String? phoneNumber,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}