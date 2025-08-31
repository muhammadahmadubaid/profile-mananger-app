class ProfileModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String? profileImageUrl;
  final String? documentUrl;
  final String? documentName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    this.profileImageUrl,
    this.documentUrl,
    this.documentName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return ProfileModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      profileImageUrl: map['profileImageUrl'],
      documentUrl: map['documentUrl'],
      documentName: map['documentName'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'profileImageUrl': profileImageUrl,
      'documentUrl': documentUrl,
      'documentName': documentName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  ProfileModel copyWith({
    String? name,
    String? email,
    int? age,
    String? profileImageUrl,
    String? documentUrl,
    String? documentName,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      documentName: documentName ?? this.documentName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
