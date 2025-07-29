class MenuItemModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? regularPrice; // Para itens em promoção
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final bool isOnPromotion; // Novo campo da API
  final int preparationTime; // em minutos
  final List<String> allergens;
  final bool isPopular;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.regularPrice,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.isOnPromotion = false,
    this.preparationTime = 15,
    this.allergens = const [],
    this.isPopular = false,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: double.tryParse(json['current_price']?.toString() ?? '0') ?? 0.0,
      regularPrice: double.tryParse(json['regular_price']?.toString() ?? '0'),
      description: json['description'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      isOnPromotion: json['is_on_promotion'] ?? false,
      preparationTime: json['preparation_time'] ?? 15,
      allergens: List<String>.from(json['allergens'] ?? []),
      isPopular: json['is_popular'] ?? false,
    );
  }

  // Factory constructor para dados da API do seu projeto
  factory MenuItemModel.fromApiData(Map<String, dynamic> product, String categoryName) {
    return MenuItemModel(
      id: product['id']?.toString() ?? '',
      name: product['name'] ?? '',
      category: categoryName,
      price: double.tryParse(product['current_price']?.toString() ?? '0') ?? 0.0,
      regularPrice: double.tryParse(product['regular_price']?.toString() ?? '0'),
      description: product['description'] ?? '',
      imageUrl: product['image_url'],
      isAvailable: true, // Assumir que está disponível se não especificado
      isOnPromotion: product['is_on_promotion'] ?? false,
      preparationTime: _estimatePreparationTime(categoryName),
      allergens: [], // Por enquanto vazio, pode ser adicionado depois
      isPopular: product['is_on_promotion'] ?? false, // Items em promoção como populares por enquanto
    );
  }

  // Método helper para estimar tempo de preparo baseado na categoria
  static int _estimatePreparationTime(String category) {
    switch (category.toLowerCase()) {
      case 'bebidas':
      case 'drinks':
        return 3;
      case 'entradas':
      case 'starters':
      case 'appetizers':
        return 8;
      case 'sobremesas':
      case 'desserts':
        return 6;
      case 'pratos principais':
      case 'main course':
      case 'principais':
        return 15;
      case 'saladas':
      case 'salads':
        return 5;
      default:
        return 10;
    }
  }

  String get formattedPrice => 'MT ${price.toStringAsFixed(2)}';
  String get formattedRegularPrice => regularPrice != null ? 'MT ${regularPrice!.toStringAsFixed(2)}' : '';
  String get shortName => name.length > 20 ? '${name.substring(0, 20)}...' : name;
  
  // Calcular desconto se em promoção
  double get discountPercentage {
    if (isOnPromotion && regularPrice != null && regularPrice! > price) {
      return ((regularPrice! - price) / regularPrice!) * 100;
    }
    return 0.0;
  }
  
  String get formattedDiscount => '${discountPercentage.toStringAsFixed(0)}% OFF';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'regular_price': regularPrice,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'is_on_promotion': isOnPromotion,
      'preparation_time': preparationTime,
      'allergens': allergens,
      'is_popular': isPopular,
    };
  }
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
  double get totalRegularPrice => (menuItem.regularPrice ?? menuItem.price) * quantity;
  String get formattedTotal => 'MT ${totalPrice.toStringAsFixed(2)}';
  String get formattedRegularTotal => 'MT ${totalRegularPrice.toStringAsFixed(2)}';
  
  // Economia total se o item estiver em promoção
  double get totalSavings => totalRegularPrice - totalPrice;
  String get formattedSavings => 'MT ${totalSavings.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'notes': notes,
      'total_price': totalPrice,
    };
  }
}