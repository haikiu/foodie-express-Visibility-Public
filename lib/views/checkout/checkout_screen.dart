
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/local_storage_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  final OrderService _orderService = OrderService();
  final LocalStorageService _localStorageService =
      LocalStorageService();

  String _paymentMethod = 'Tiền mặt khi nhận hàng';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDeliveryInfo();
  }

  // Tải thông tin nhận hàng đã lưu trên thiết bị.
  Future<void> _loadDeliveryInfo() async {
    try {
      final info = await _localStorageService.getDeliveryInfo();

      if (!mounted) return;

      setState(() {
        _nameController.text = info['name'] ?? '';
        _phoneController.text = info['phone'] ?? '';
        _addressController.text = info['address'] ?? '';
      });
    } catch (_) {
      // Không làm ảnh hưởng đến màn hình thanh toán
      // nếu không thể đọc dữ liệu cục bộ.
    }
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}đ';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng đang trống.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Gửi yêu cầu tạo đơn hàng lên REST API.
      final result = await _orderService.createOrder(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        note: _noteController.text.trim(),
        paymentMethod: _paymentMethod,
        items: List.of(cart.items),
      );

      if (!mounted) return;

      final order = result['order'] as Map<String, dynamic>?;
      final orderId = order?['id']?.toString() ?? '';

      // Lưu thông tin nhận hàng vào bộ nhớ cục bộ.
      // Nếu lưu thất bại, đơn hàng API vẫn được xem là thành công.
      try {
        await _localStorageService.saveDeliveryInfo(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
      } catch (_) {
        // Không làm thất bại đơn hàng nếu SharedPreferences lỗi.
      }

      if (!mounted) return;

      // Xóa giỏ hàng sau khi tạo đơn thành công.
      cart.clearCart();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 55,
          ),
          title: const Text('Đặt hàng thành công!'),
          content: Text(
            'Đơn hàng của bạn đã được tạo.\n'
            'Mã đơn hàng: $orderId\n'
            'Trạng thái: Chờ xác nhận',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
              child: const Text('Hoàn tất'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thất bại: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin nhận hàng',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên người nhận',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^[0-9]{10,11}$')
                              .hasMatch(value.trim())) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ giao hàng',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập địa chỉ giao hàng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (không bắt buộc)',
                      prefixIcon: Icon(Icons.note_alt),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  RadioGroup<String>(
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentMethod = value);
                      }
                    },
                    child: const Column(
                      children: [
                        RadioListTile<String>(
                          value: 'Tiền mặt khi nhận hàng',
                          title: Text('Tiền mặt khi nhận hàng (COD)'),
                          secondary: Icon(Icons.money),
                        ),
                        RadioListTile<String>(
                          value: 'Chuyển khoản',
                          title: Text('Chuyển khoản ngân hàng'),
                          secondary: Icon(Icons.account_balance),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Đơn hàng của bạn',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            item.icon,
                            style: const TextStyle(fontSize: 25),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${item.name} x${item.quantity}',
                            ),
                          ),
                          Text(
                            formatPrice(item.price * item.quantity),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatPrice(cart.totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || cart.items.isEmpty
                          ? null
                          : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'XÁC NHẬN ĐẶT HÀNG',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
