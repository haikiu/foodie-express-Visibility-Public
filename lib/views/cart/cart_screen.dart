
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}đ';
  }

  String customizationDetails(CartItem item) {
    final details = <String>[];

    if (item.size != 'Không áp dụng') {
      details.add('Size ${item.size}');
    }

    if (item.toppings.isNotEmpty) {
      details.add('Topping: ${item.toppings.join(', ')}');
    }

    if (item.sugar != 'Không áp dụng') {
      details.add('Đường: ${item.sugar}');
    }

    if (item.ice != 'Không áp dụng') {
      details.add('Đá: ${item.ice}');
    }

    return details.isEmpty ? 'Mặc định' : details.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Giỏ hàng đang trống',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Hãy chọn món ăn yêu thích của bạn!'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.icon,
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),

                                  Text(
                                    customizationDetails(item),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 7),

                                  Text(
                                    formatPrice(item.price),
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cart.decreaseQuantity(item);
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        color: Colors.deepOrange,
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          cart.increaseQuantity(item);
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        color: Colors.deepOrange,
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                cart.removeItem(item);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              tooltip: 'Xóa sản phẩm',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng số lượng:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${cart.totalItems} sản phẩm',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatPrice(cart.totalPrice),
                          style: const TextStyle(
                            fontSize: 21,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'TIẾN HÀNH THANH TOÁN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
