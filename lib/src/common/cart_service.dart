class CartService {
  static List<Map<String, dynamic>> itemArr = [];

  static void addToCart(String name, int qty, double price) {
    // Verifica se o item já existe
    var existingItem = itemArr.firstWhere(
      (item) => item["name"] == name,
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      print("Item já existe no carrinho" + existingItem.toString() + " qty: " + qty.toString());
      existingItem["qty"] = qty.toString();
          // (int.parse(existingItem["qty"]) + qty).toString();
    } else {
      itemArr.add({"name": name, "qty": qty.toString(), "price": price});
    }
  }

  static double getTotal() {
    return itemArr.fold(
      0,
      (sum, item) => sum + (int.parse(item["qty"]) * item["price"]),
    );
  }

  static void clearCart() {
    itemArr.clear();
  }

  static List<Map<String, dynamic>> getCartItems() {
    return itemArr;
  }
}
