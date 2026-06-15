import 'dart:io';

void main() async {
  final Map<String, String> replacements = {
    'home_screen.dart': 'home/home_screen.dart',
    'login_screen.dart': 'auth/login_screen.dart',
    'register_screen.dart': 'auth/register_screen.dart',
    'book_detail_screen.dart': 'book/book_detail_screen.dart',
    'book_list_screen.dart': 'book/book_list_screen.dart',
    'category_books_screen.dart': 'book/category_books_screen.dart',
    'favorite_screen.dart': 'book/favorite_screen.dart',
    'top_ordered_books_screen.dart': 'book/top_ordered_books_screen.dart',
    'product_detail_screen.dart': 'book/product_detail_screen.dart',
    'edit_book_screen.dart': 'book/edit_book_screen.dart',
    'cart_screen.dart': 'order/cart_screen.dart',
    'checkout_screen.dart': 'order/checkout_screen.dart',
    'confirm_order_screen.dart': 'order/confirm_order_screen.dart',
    'order_list_screen.dart': 'order/order_list_screen.dart',
    'return_info_screen.dart': 'order/return_info_screen.dart',
    'return_policy_screen.dart': 'order/return_policy_screen.dart',
    'profile_screen.dart': 'profile/profile_screen.dart',
    'edit_profile_screen.dart': 'profile/edit_profile_screen.dart',
    'user_info_screen.dart': 'profile/user_info_screen.dart',
    'wallet_screen.dart': 'profile/wallet_screen.dart',
    'discount_screen.dart': 'profile/discount_screen.dart',
  };

  final libDir = Directory('lib');
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;

      // Handle package imports
      for (final entry in replacements.entries) {
        final oldImport1 = 'package:book_app/screens/${entry.key}';
        final newImport1 = 'package:book_app/screens/${entry.value}';
        if (content.contains(oldImport1)) {
          content = content.replaceAll(oldImport1, newImport1);
          changed = true;
        }

        // Handle relative imports like '../screens/home_screen.dart'
        final oldImport2 = '/screens/${entry.key}';
        final newImport2 = '/screens/${entry.value}';
        if (content.contains(oldImport2)) {
          content = content.replaceAll(oldImport2, newImport2);
          changed = true;
        }
      }
      
      // Handle imports like import 'login_screen.dart';
      for (final entry in replacements.entries) {
        final regex = RegExp(r"import '([a-zA-Z0-9_]+_screen\.dart)'");
        content = content.replaceAllMapped(regex, (match) {
          final matchedFile = match.group(1);
          if (replacements.containsKey(matchedFile)) {
            final target = replacements[matchedFile]!;
            return "import '../$target'";
          }
          return match.group(0)!;
        });
      }

      if (changed) {
        await entity.writeAsString(content);
        print('Updated ${entity.path}');
      }
    }
  }
}
