
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final int price;
  final String icon;

  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.price,
    required this.icon,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = 'M';
  String selectedSugar = '100%';
  String selectedIce = '100%';

  final List<String> selectedToppings = [];

  bool get isDrink => widget.name.toLowerCase().contains('trà') ||
      widget.name.toLowerCase().contains('nước') ||
      widget.name.toLowerCase().contains('cà phê') ||
      widget.name.toLowerCase().contains('sữa');

  List<String> get toppings {
    if (isDrink) {
      return [
        'Trân châu đen',
        'Thạch trái cây',
        'Phô mai',
        'Kem cheese',
      ];
    }

    if (widget.name.toLowerCase().contains('burger')) {
      return [
        'Thêm phô mai',
        'Thêm thịt xông khói',
        'Thêm trứng',
        'Thêm rau',
      ];
    }

    if (widget.name.toLowerCase().contains('pizza')) {
      return [
        'Thêm phô mai',
        'Thêm xúc xích',
        'Thêm hải sản',
        'Thêm nấm',
      ];
    }

    if (widget.name.toLowerCase().contains('gà')) {
      return [
        'Sốt cay',
        'Sốt phô mai',
        'Khoai tây chiên',
        'Gà thêm miếng',
      ];
    }

    return [
      'Thêm phô mai',
      'Thêm sốt',
    ];
  }

  int get extraPrice => selectedToppings.length * 5000;

  int get sizePrice => isDrink && selectedSize == 'L' ? 10000 : 0;

  int get finalPrice => widget.price + sizePrice + extraPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tùy chỉnh món ăn'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(widget.icon, style: const TextStyle(fontSize: 90)),
                  const SizedBox(height: 12),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.price} đ',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            if (isDrink) ...[
              const Text(
                'Chọn kích cỡ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              RadioGroup<String>(
                groupValue: selectedSize,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedSize = value);
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('Size M'),
                      value: 'M',
                    ),
                    RadioListTile<String>(
                      title: Text('Size L (+10.000đ)'),
                      value: 'L',
                    ),
                  ],
                ),
              ),
            ],

            Text(
              isDrink ? 'Chọn topping (+5.000đ/món)' : 'Tùy chọn thêm (+5.000đ/món)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ...toppings.map((topping) {
              return CheckboxListTile(
                title: Text(topping),
                value: selectedToppings.contains(topping),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedToppings.add(topping);
                    } else {
                      selectedToppings.remove(topping);
                    }
                  });
                },
              );
            }),

            if (isDrink) ...[
              const SizedBox(height: 15),
              const Text(
                'Mức đường',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedSugar,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ['0%', '30%', '50%', '70%', '100%']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedSugar = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Lượng đá',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedIce,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ['Không đá', '30%', '50%', '70%', '100%']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedIce = value);
                  }
                },
              ),
            ],

            const SizedBox(height: 28),

            Text(
              'Tổng tiền: $finalPrice đ',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  context.read<CartProvider>().addItem(
                        name: widget.name,
                        price: finalPrice,
                        icon: widget.icon,
                        size: isDrink ? selectedSize : 'Không áp dụng',
                        toppings: List<String>.from(selectedToppings),
                        sugar: isDrink ? selectedSugar : 'Không áp dụng',
                        ice: isDrink ? selectedIce : 'Không áp dụng',
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm món vào giỏ hàng!'),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
