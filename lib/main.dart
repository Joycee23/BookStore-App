import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/discount_provider.dart';

import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/return_policy_screen.dart';
import 'screens/return_info_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/wallet_screen.dart';
import 'admin_screen/admin_home_screen.dart';
import 'admin_screen/return_requests_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");



  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Store',
      theme: AppTheme.darkTheme,
      home: _getInitialScreen(authProvider),
      routes: {
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
        '/checkout': (context) => CheckoutScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user_info': (context) => UserInfoScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
        '/return_policy': (context) => ReturnPolicyScreen(),
        '/return_info': (context) => ReturnInfoScreen(),
        '/orders': (context) => OrderListScreen(),
        '/admin': (context) => AdminHomeScreen(),
        '/return_requests': (context) => ReturnRequestsScreen(),
        '/wallet': (context) {
          final userId = authProvider.userId;
          if (userId == null) {
            return LoginScreen();
          }
          return WalletScreen(userId: userId);
        },
      },
    );
  }

  Widget _getInitialScreen(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      if (authProvider.email == 'admin@gmail.com') {
        return AdminHomeScreen();
      } else if (authProvider.fullName.isNotEmpty) {
        return HomeScreen();
      } else {
        return UserInfoScreen();
      }
    } else {
      return LoginScreen();
    }
  }
}
