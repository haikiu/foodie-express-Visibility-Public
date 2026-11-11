
import 'package:flutter/material.dart';
import '../../services/order_history_service.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  String formatDate(dynamic timestamp) {
    if (timestamp is! num) return 'Chưa xác định';
    final date = DateTime.fromMillisecondsSinceEpoch(
      timestamp.toInt(),
    );
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String formatPrice(dynamic value) {
    final price = value is num ? value.toInt() : 0;
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: OrderHistoryService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Không thể tải lịch sử đơn hàng.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 65, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Bạn chưa có đơn hàng nào.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final id = order['id']?.toString() ?? '';
              final status = order['status']?.toString() ??
                  'Chờ xác nhận';

              final items = order['items'];
              final itemCount = items is List
                  ? items.length
                  : items is Map
                      ? items.length
                      : 0;

              final total = order['total'] ??
                  order['totalPrice'] ??
                  order['totalAmount'] ??
                  0;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE9DC),
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.deepOrange,
                    ),
                  ),
                  title: Text(
                    'Đơn hàng #${id.length > 8 ? id.substring(0, 8) : id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trạng thái: $status'),
                        Text('Số loại món: $itemCount'),
                        Text('Ngày đặt: ${formatDate(order['createdAt'])}'),
                        Text('Tổng tiền: ${formatPrice(total)}'),
                        const SizedBox(height: 8),
                        const Text(
                          'Trạng thái được cập nhật theo thời gian thực',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
