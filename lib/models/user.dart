class User {
  final String id;
  final String email;
  final String password;
  double walletBalance;

  User({required this.id, required this.email, required this.password, this.walletBalance = 0.0});
}
