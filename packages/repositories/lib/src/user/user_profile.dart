import 'package:core/core.dart';

enum Gender {
  male,
  female,
  other,
  unknown;

  static Gender parse(Object? raw) => Gender.values.firstWhere(
    (g) => g.name == raw?.toString().toLowerCase(),
    orElse: () => Gender.unknown,
  );
}

/// The signed-in user's profile.
final class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender = Gender.unknown,
  });

  factory UserProfile.fromJson(JsonMap json) => UserProfile(
    id: json['id'].toString(),
    fullName: (json['fullName'] ?? json['full_name'] ?? '') as String,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
    dateOfBirth: switch (json['dateOfBirth'] ?? json['date_of_birth']) {
      final String s => DateTime.tryParse(s),
      _ => null,
    },
    gender: Gender.parse(json['gender']),
  );

  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final Gender gender;

  JsonMap toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': ?phone,
    'email': ?email,
    'avatarUrl': ?avatarUrl,
    if (dateOfBirth != null)
      'dateOfBirth': dateOfBirth!.toIso8601String().split('T').first,
    'gender': gender.name,
  };

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    DateTime? dateOfBirth,
    Gender? gender,
  }) => UserProfile(
    id: id,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    gender: gender ?? this.gender,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.fullName == fullName &&
      other.phone == phone &&
      other.email == email &&
      other.avatarUrl == avatarUrl &&
      other.dateOfBirth == dateOfBirth &&
      other.gender == gender;

  @override
  int get hashCode =>
      Object.hash(id, fullName, phone, email, avatarUrl, dateOfBirth, gender);
}

/// Partial update payload – only non-null fields are sent.
final class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.gender,
  });

  final String? fullName;
  final String? email;
  final DateTime? dateOfBirth;
  final Gender? gender;

  JsonMap toJson() => {
    'fullName': ?fullName,
    'email': ?email,
    if (dateOfBirth != null)
      'dateOfBirth': dateOfBirth!.toIso8601String().split('T').first,
    if (gender != null) 'gender': gender!.name,
  };
}
