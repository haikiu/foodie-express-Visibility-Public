
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  late final Future<void> _loadFuture;
  Future<void> _writeQueue = Future.value();

  bool _hasLocalChanges = false;

  CartProvider() {
    _loadFuture = _loadCart();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  // Tải giỏ hàng đã lưu
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('cart_items');

      if (savedData != null && !_hasLocalChanges) {
        final List<dynamic> data = jsonDecode(savedData);

        _items.clear();

        for (final item in data) {
          _items.add(
            CartItem(
              name: item['name'].toString(),
              price: (item['price'] as num).toInt(),
              icon: item['icon'].toString(),
              size: (item['size'] ?? 'M').toString(),
              toppings: List<String>.from(
                item['toppings'] ?? [],
              ),
              sugar: (item['sugar'] ?? '100%').toString(),
              ice: (item['ice'] ?? '100%').toString(),
              quantity: (item['quantity'] as num).toInt(),
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải giỏ hàng: $e');
    }
  }

  // Lưu giỏ hàng tuần tự
  void _saveCart() {
    _writeQueue = _writeQueue.then((_) async {
      await _loadFuture;

      final prefs = await SharedPreferences.getInstance();

      final data = _items.map((item) {
        return {
          'name': item.name,
          'price': item.price,
          'icon': item.icon,
          'size': item.size,
          'toppings': item.toppings,
          'sugar': item.sugar,
          'ice': item.ice,
          'quantity': item.quantity,
        };
      }).toList();

      await prefs.setString('cart_items', jsonEncode(data));

      debugPrint('Đã lưu giỏ hàng: ${jsonEncode(data)}');
    }).catchError((error) {
      debugPrint('Lỗi lưu giỏ hàng: $error');
    });
  }

  // So sánh cấu hình để tránh gộp nhầm món
  bool _sameConfiguration(
    CartItem item, {
    required String name,
    required String size,
    required List<String> toppings,
    required String sugar,
    required String ice,
  }) {
    if (item.name != name ||
        item.size != size ||
        item.sugar != sugar ||
        item.ice != ice ||
        item.toppings.length != toppings.length) {
      return false;
    }

    return item.toppings.toSet().containsAll(toppings);
  }

  // Thêm món vào giỏ hàng
  void addItem({
    required String name,
    required int price,
    required String icon,
    String size = 'M',
    List<String> toppings = const [],
    String sugar = '100%',
    String ice = '100%',
  }) {
    _hasLocalChanges = true;

    final index = _items.indexWhere(
      (item) => _sameConfiguration(
        item,
        name: name,
        size: size,
        toppings: toppings,
        sugar: sugar,
        ice: ice,
      ),
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItem(
          name: name,
          price: price,
          icon: icon,
          size: size,
          toppings: List<String>.from(toppings),
          sugar: sugar,
          ice: ice,
        ),
      );
    }

    notifyListeners();
    _saveCart();
  }

  void increaseQuantity(CartItem item) {
    _hasLocalChanges = true;
    item.quantity++;
    notifyListeners();
    _saveCart();
  }

  void decreaseQuantity(CartItem item) {
    _hasLocalChanges = true;

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }

    notifyListeners();
    _saveCart();
  }

  void removeItem(CartItem item) {
    _hasLocalChanges = true;
    _items.remove(item);
    notifyListeners();
    _saveCart();
  }

  void clearCart() {
    _hasLocalChanges = true;
    _items.clear();
    notifyListeners();
    _saveCart();
  }
}
