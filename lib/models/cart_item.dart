
class CartItem {
  final String name;
  final int price;
  final String icon;

  final String size;
  final List<String> toppings;
  final String sugar;
  final String ice;

  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.icon,
    this.size = 'M',
    this.toppings = const [],
    this.sugar = '100%',
    this.ice = '100%',
    this.quantity = 1,
  });
}
