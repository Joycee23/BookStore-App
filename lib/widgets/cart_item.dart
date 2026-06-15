import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        item.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/images/placeholder.jpg', width: 50, height: 50),
      ),
      title: Text(item.title),
      subtitle: Text('Giá: \$${item.price.toStringAsFixed(2)}\nSố lượng: ${item.quantity}'),
      trailing: IconButton(
        icon: const Icon(Icons.remove_shopping_cart),
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.userId != null) {
            Provider.of<CartProvider>(context, listen: false).removeItem(authProvider.userId!, item.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.title} đã bị xoá khỏi giỏ hàng!')),
            );
          }
        },
      ),
    );
  }
}
