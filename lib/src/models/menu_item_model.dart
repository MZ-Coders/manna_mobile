class MenuItemModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final int preparationTime; // em minutos
  final List<String> allergens;
  final bool isPopular;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.preparationTime = 15,
    this.allergens = const [],
    this.isPopular = false,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      preparationTime: json['preparation_time'] ?? 15,
      allergens: List<String>.from(json['allergens'] ?? []),
      isPopular: json['is_popular'] ?? false,
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get shortName => name.length > 20 ? '${name.substring(0, 20)}...' : name;
}

class CartItemModel {
  final MenuItemModel menuItem;
  int quantity;
  String? notes;

  CartItemModel({
    required this.menuItem,
    this.quantity = 1,
    this.notes,
  });

  double get totalPrice => menuItem.price * quantity;
  String get formattedTotal => '\$${totalPrice.toStringAsFixed(2)}';
}