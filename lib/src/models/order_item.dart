class OrderItem {
  final String image;
  final String title;
  final double price;
  int qty;

  OrderItem({
    required this.image,
    required this.title,
    required this.price,
    this.qty = 1,
  });
}
