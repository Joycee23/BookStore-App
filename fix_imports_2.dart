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

  // 1. Fix main.dart and other files OUTSIDE of lib/screens
  final libDir = Directory('lib');
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Skip files inside lib/screens for this first pass
      if (entity.path.replaceAll('\\\\', '/').contains('/screens/')) continue;
      
      String content = await entity.readAsString();
      bool changed = false;

      for (final entry in replacements.entries) {
        final oldImport = "import 'screens/${entry.key}';";
        final newImport = "import 'screens/${entry.value}';";
        if (content.contains(oldImport)) {
          content = content.replaceAll(oldImport, newImport);
          changed = true;
        }
      }

      if (changed) {
        await entity.writeAsString(content);
        print('Updated outside screens: \${entity.path}');
      }
    }
  }

  // 2. Fix files INSIDE lib/screens
  final screensDir = Directory('lib/screens');
  await for (final entity in screensDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;

      // Because the files moved ONE level deeper, any import starting with '../' needs to become '../../'
      // But only do this ONCE. If it's already '../../' don't make it '../../../'.
      // A safe way: change '../' to '../../' BUT exclude anything that is already '../../'
      // Wait, let's just do: convert all `import '../` to `import '../../`
      final regexLevel = RegExp(r"import '\.\./");
      // But wait! if we run the script multiple times, it will keep adding `../`.
      // Let's use absolute package imports! This is 100% safe.
      
      // Let's replace `import '../utils/` with `import 'package:book_app/utils/`
      // Let's replace `import '../models/` with `import 'package:book_app/models/`
      // Let's replace `import '../providers/` with `import 'package:book_app/providers/`
      // Let's replace `import '../widgets/` with `import 'package:book_app/widgets/`
      // Let's replace `import '../screens/` with `import 'package:book_app/screens/`
      final folders = ['utils', 'models', 'providers', 'widgets', 'screens'];
      for (final folder in folders) {
        final r1 = "import '../$folder/";
        final r2 = "import 'package:book_app/$folder/";
        if (content.contains(r1)) {
          content = content.replaceAll(r1, r2);
          changed = true;
        }
        final r3 = "import '../../$folder/";
        if (content.contains(r3)) {
          content = content.replaceAll(r3, r2);
          changed = true;
        }
      }

      // Handle inter-screen imports like `import 'login_screen.dart';`
      for (final entry in replacements.entries) {
        final regex = RegExp("import '" + entry.key + "';");
        if (content.contains(regex)) {
          final target = entry.value;
          content = content.replaceAll(regex, "import 'package:book_app/screens/$target';");
          changed = true;
        }
      }

      if (changed) {
        await entity.writeAsString(content);
        print('Updated inside screens: \${entity.path}');
      }
    }
  }
}
