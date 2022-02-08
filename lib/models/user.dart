class User {
  final String email;
  final String name;
  final String password;
  final String imageUrl;
  final bool premium;

  const User({
    required this.email,
    required this.name,
    required this.password,
    required this.imageUrl,
    required this.premium,
  });
}
