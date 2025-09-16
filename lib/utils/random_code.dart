import 'dart:math';

String generateRandomCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
  final rand = Random();
  return List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();
}
