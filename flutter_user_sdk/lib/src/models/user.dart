class User {
  final String firstName;
  final String lastName;
  final String avatarUrl;

  const User({
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final buffer = StringBuffer();
    if (firstName.isNotEmpty) {
      buffer.write(firstName[0]);
    }
    if (lastName.isNotEmpty) {
      buffer.write(lastName[0]);
    }
    return buffer.isEmpty ? '?' : buffer.toString().toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      avatarUrl: json['avatar']?.toString() ?? '',
    );
  }
}
