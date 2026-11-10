
import 'package:dio/dio.dart';
import '../models/cart_item.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:5000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String phone,
    required String address,
    required String note,
    required String paymentMethod,
    required List<CartItem> items,
  }) async {
    try {
      final response = await _dio.post(
        '/api/orders',
        data: {
          'customerName': customerName,
          'phone': phone,
          'address': address,
          'note': note,
          'paymentMethod': paymentMethod,
          'items': items.map((item) => {
            'name': item.name,
            'price': item.price,
            'icon': item.icon,
            'size': item.size,
            'toppings': item.toppings,
            'sugar': item.sugar,
            'ice': item.ice,
            'quantity': item.quantity,
          }).toList(),
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString()
          : null;

      throw Exception(
        message ?? e.message ?? 'Không thể kết nối Backend.',
      );
    }
  }
}
