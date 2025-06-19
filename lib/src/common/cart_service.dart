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

   static void removeFromCart(int index) {
    if (index >= 0 && index < itemArr.length) {
      itemArr.removeAt(index);
      print("Item removido do carrinho. Total de itens: ${itemArr.length}");
    }
  }

  static void updateQuantity(int index, int newQty) {
    if (index >= 0 && index < itemArr.length && newQty > 0) {
      itemArr[index]["qty"] = newQty.toString();
      print("Quantidade atualizada para: $newQty");
    }
  }

  // Função extra útil: remover item por nome
  static void removeItemByName(String name) {
    itemArr.removeWhere((item) => item["name"] == name);
    print("Item '$name' removido do carrinho");
  }

  // Função extra útil: verificar se item existe
  static bool itemExists(String name) {
    return itemArr.any((item) => item["name"] == name);
  }

  // Função extra útil: obter quantidade total de itens
  static int getTotalItems() {
    return itemArr.fold(0, (sum, item) => sum + int.parse(item["qty"]));
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
