import 'package:dribbble_challenge/src/core/theme/app_colors.dart';
import 'package:dribbble_challenge/src/models/order_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomePosPage extends StatefulWidget {
  const HomePosPage({Key? key}) : super(key: key);

 

  @override
  State<HomePosPage> createState() => _HomePosPageState();
}

class _HomePosPageState extends State<HomePosPage> {
  List<OrderItem> orderList = [];
  String currentTab = 'Burger'; // Adicionado para controlar a tab ativa
  
  // Método para trocar de tab
  void changeTab(String tab) {
    setState(() {
      currentTab = tab;
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 14,
          child: Column(
            children: [
              _topMenu(
                title: 'Casa Das Pizzas',
                subTitle: '20 October 2022',
                action: _search(),
              ),
             // Atualização da lista de tabs no Container com ListView horizontal
Container(
  height: 100,
  padding: const EdgeInsets.symmetric(vertical: 24),
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: [
      _itemTab(
        icon: 'assets/icons/icon-burger.png',
        title: 'Burger',
        isActive: currentTab == 'Burger',
        onTap: () => changeTab('Burger'),
      ),
      _itemTab(
        icon: 'assets/icons/icon-noodles.png',
        title: 'Noodles',
        isActive: currentTab == 'Noodles',
        onTap: () => changeTab('Noodles'),
      ),
      _itemTab(
        icon: 'assets/icons/icon-drinks.png',
        title: 'Drinks',
        isActive: currentTab == 'Drinks',
        onTap: () => changeTab('Drinks'),
      ),
      _itemTab(
        icon: 'assets/icons/icon-desserts.png',
        title: 'Desserts',
        isActive: currentTab == 'Desserts',
        onTap: () => changeTab('Desserts'),
      ),
      _itemTab(
        icon: 'assets/items/SORVETE-LUIGI-1.6L-MORANGO-COM-CHANTILLY.png',  // Você precisará adicionar este ícone
        title: 'Sorvetes',
        isActive: currentTab == 'Sorvetes',
        onTap: () => changeTab('Sorvetes'),
      )
    ],
  ),
),
            Expanded(
                child: _buildGridForCurrentTab(),
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _topMenu(
                title: 'Order',
                subTitle: 'Table 8',
                action: Container(),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: orderList.map((item) {
    return _itemOrder(
      image: item.image,
      title: item.title,
      qty: item.qty.toString(),
      price: '\$${item.price.toStringAsFixed(2)}',
    );
  }).toList(),
                ),
              ),
             // Substitua a parte do resumo do pedido no método build por este código
// Substitua a parte do resumo do pedido por este código
Expanded(
  child: Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sub Total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              '\$${calculateSubtotal().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tax',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              '\$${calculateTax(calculateSubtotal()).toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          height: 2,
          width: double.infinity,
          color: AppColors.textfield, // Cor mais clara para o separador
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              '\$${calculateTotal(calculateSubtotal(), calculateTax(calculateSubtotal())).toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary, // Usando a cor primária definida
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.print, size: 16),
              SizedBox(width: 6),
              Text('Print Bills')
            ],
          ),
        ),
      ],
    ),
  ),
)            ],
          ),
        ),
      ],
    );
  }

Widget _itemOrder({
  required String image,
  required String title,
  required String qty,
  required String price,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.textfield,
          ),
          child: Center(
            child: Text(
              qty,
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _item({
  required String image,
  required String title,
  required String price,
  required int quantity,
  required String item,
  required Function onAdd,
  required Function onRemove,
}) {
  return Container(
    margin: const EdgeInsets.only(right: 20, bottom: 20),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              price,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Text(
            //   item,
            //   style: TextStyle(
            //     color: AppColors.secondaryText,
            //     fontSize: 12,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.textfield,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove, 
                  color: AppColors.secondaryText,
                ),
                onPressed: () {
                  onRemove();
                },
              ),
              Text(
                quantity.toString(),
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add, 
                  color: AppColors.primary,
                ),
                onPressed: () {
                  onAdd();
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void addToOrder(String image, String title, double price) {
  setState(() {
    final index = orderList.indexWhere((item) => item.title == title);
    print(index);
    print(orderList);

    if (index != -1) {
      orderList[index].qty++;
      
      // Opcional: Mover o item atualizado para o topo da lista
      final item = orderList.removeAt(index);
      orderList.insert(0, item);
    } else {
      // Adicionar novo item no início da lista (índice 0)
      orderList.insert(0, OrderItem(image: image, title: title, price: price));
    }
  });
}

void removeFromOrder(String title) {
  setState(() {
    final index = orderList.indexWhere((item) => item.title == title);
    if (index != -1) {
      if (orderList[index].qty > 1) {
        orderList[index].qty -= 1;
      } else {
        orderList.removeAt(index);
      }
    }
  });
}

int _getQuantityFor(String title) {
  print("Titulo "+ title);
  final index = orderList.indexWhere((item) => item.title == title); 
  print("Index "+ index.toString());
  print(orderList);
  if (index != -1) {
    return orderList[index].qty;
  }
  return 0;
}

// Adicione este método na classe _HomePosPageState
double calculateSubtotal() {
  double subtotal = 0;
  for (var item in orderList) {
    subtotal += item.price * item.qty;
  }
  return subtotal;
}

// Adicione este método para calcular o imposto
double calculateTax(double subtotal) {
  // Assumindo uma taxa de imposto de 10%, você pode ajustar conforme necessário
  return subtotal * 0.10;
}

// Adicione este método para calcular o total
double calculateTotal(double subtotal, double tax) {
  return subtotal + tax;
}

  // }
  // Widget _itemTab({required String icon, required String title}) {


Widget _itemTab({
  required String icon,
  required String title,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isActive ? AppColors.primary : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 24,
            height: 24,
            color: isActive ? Colors.white : AppColors.secondaryText,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.primaryText,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
// Widget para exibir os produtos da categoria Drinks
Widget _drinksGrid() {
  return GridView.extent(
    maxCrossAxisExtent: 200,
    childAspectRatio: 1 / 1.2,
    children: [
      _item(
        image: 'assets/items/coca_2l.png', 
        title: 'Coca-Cola 2L', 
        price: '\$3.99', 
        quantity: _getQuantityFor('Coca-Cola 2L'),
        item: '15 item', 
        onAdd: () {
          addToOrder('assets/items/coca_2l.png', 'Coca-Cola 2L', 3.99);
        }, 
        onRemove: () {
          removeFromOrder('Coca-Cola 2L');
        }
      ),
      _item(
        image: 'assets/items/coca_cola_lata.png', 
        title: 'Coca-Cola Lata', 
        price: '\$1.99', 
        quantity: _getQuantityFor('Coca-Cola Lata'),
        item: '20 item', 
        onAdd: () {
          addToOrder('assets/items/coca_cola_lata.png', 'Coca-Cola Lata', 1.99);
        }, 
        onRemove: () {
          removeFromOrder('Coca-Cola Lata');
        }
      ),
      _item(
        image: 'assets/items/pepsi_lata.png', 
        title: 'Pepsi Lata', 
        price: '\$1.89', 
        quantity: _getQuantityFor('Pepsi Lata'),
        item: '18 item', 
        onAdd: () {
          addToOrder('assets/items/pepsi_lata.png', 'Pepsi Lata', 1.89);
        }, 
        onRemove: () {
          removeFromOrder('Pepsi Lata');
        }
      ),
      _item(
        image: 'assets/items/REFRESCO_200ML_LIMAO.png.png', 
        title: 'Del Valle Limão 200ml', 
        price: '\$2.29', 
        quantity: _getQuantityFor('Del Valle Limão 200ml'),
        item: '12 item', 
        onAdd: () {
          addToOrder('assets/items/REFRESCO_200ML_LIMAO.png.png', 'Del Valle Limão 200ml', 2.29);
        }, 
        onRemove: () {
          removeFromOrder('Del Valle Limão 200ml');
        }
      ),
      _item(
        image: 'assets/items/REFRESCO_200ML_UVA.png.png', 
        title: 'Del Valle Uva 200ml', 
        price: '\$2.29', 
        quantity: _getQuantityFor('Del Valle Uva 200ml'),
        item: '10 item', 
        onAdd: () {
          addToOrder('assets/items/REFRESCO_200ML_UVA.png.png', 'Del Valle Uva 200ml', 2.29);
        }, 
        onRemove: () {
          removeFromOrder('Del Valle Uva 200ml');
        }
      ),
      _item(
        image: 'assets/items/REFRESCO_200L_LARANJA.png.png', 
        title: 'Del Valle Laranja 200ml', 
        price: '\$2.29', 
        quantity: _getQuantityFor('Del Valle Laranja 200ml'),
        item: '14 item', 
        onAdd: () {
          addToOrder('assets/items/REFRESCO_200L_LARANJA.png.png', 'Del Valle Laranja 200ml', 2.29);
        }, 
        onRemove: () {
          removeFromOrder('Del Valle Laranja 200ml');
        }
      ),
      _item(
        image: 'assets/items/BEBIDA-LACTEA-PULSI-GARRAFA-11KG-MORANGO.png', 
        title: 'Pulsi Morango 1L', 
        price: '\$4.49', 
        quantity: _getQuantityFor('Pulsi Morango 1L'),
        item: '8 item', 
        onAdd: () {
          addToOrder('assets/items/BEBIDA-LACTEA-PULSI-GARRAFA-11KG-MORANGO.png', 'Pulsi Morango 1L', 4.49);
        }, 
        onRemove: () {
          removeFromOrder('Pulsi Morango 1L');
        }
      )
    ],
  );
}

// Widget para exibir os produtos da categoria Sorvetes
Widget _sorvetesGrid() {
  return GridView.extent(
    maxCrossAxisExtent: 200,
    childAspectRatio: 1 / 1.2,
    children: [
      _item(
        image: 'assets/items/SORVETE-LUIGI-1.6L-MORANGO-COM-CHANTILLY.png', 
        title: 'Sorvete Morango c/ Chantilly', 
        price: '\$12.99', 
        quantity: _getQuantityFor('Sorvete Morango c/ Chantilly'),
        item: '5 item', 
        onAdd: () {
          addToOrder('assets/items/SORVETE-LUIGI-1.6L-MORANGO-COM-CHANTILLY.png', 'Sorvete Morango c/ Chantilly', 12.99);
        }, 
        onRemove: () {
          removeFromOrder('Sorvete Morango c/ Chantilly');
        }
      ),
      _item(
        image: 'assets/items/SORVETE-PALETITAS-POTE-500ML-COOKIES-TRU.png', 
        title: 'Sorvete Cookies 500ml', 
        price: '\$9.99', 
        quantity: _getQuantityFor('Sorvete Cookies 500ml'),
        item: '7 item', 
        onAdd: () {
          addToOrder('assets/items/SORVETE-PALETITAS-POTE-500ML-COOKIES-TRU.png', 'Sorvete Cookies 500ml', 9.99);
        }, 
        onRemove: () {
          removeFromOrder('Sorvete Cookies 500ml');
        }
      ),
      _item(
        image: 'assets/items/IOGURTE-NESTLE-GREGO-400G-FRUTAS-VERMELHAS.png', 
        title: 'Iogurte Grego 400g', 
        price: '\$5.99', 
        quantity: _getQuantityFor('Iogurte Grego 400g'),
        item: '6 item', 
        onAdd: () {
          addToOrder('assets/items/IOGURTE-NESTLE-GREGO-400G-FRUTAS-VERMELHAS.png', 'Iogurte Grego 400g', 5.99);
        }, 
        onRemove: () {
          removeFromOrder('Iogurte Grego 400g');
        }
      ),
    ],
  );
}
 
  Widget _topMenu({
    required String title,
    required String subTitle,
    required Widget action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primarySpecial,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subTitle,
              style: const TextStyle(
                color: AppColors.secondaryTextSpecial,
                fontSize: 10,
              ),
            ),
          ],
        ),
        Expanded(flex: 1, child: Container(width: double.infinity)),
        Expanded(flex: 5, child: action),
      ],
    );
  }

  Widget _search() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.textfieldSpecial,
        ),
        child: Row(
          children: const [
            Icon(
              Icons.search,
              color: AppColors.secondaryTextSpecial,
            ),
            SizedBox(width: 10),
            Text(
              'Search menu here...',
              style: TextStyle(color: AppColors.placeholderSpecial, fontSize: 11),
            )
          ],
        ));
  }

  // Adicione este método à classe _HomePosPageState para exibir o grid correspondente à tab selecionada
Widget _buildGridForCurrentTab() {
  switch (currentTab) {
    case 'Burger':
      return _burgerGrid();
    case 'Drinks':
      return _drinksGrid();
    case 'Sorvetes':
      return _sorvetesGrid();
    case 'Noodles':
      return _noodlesGrid(); // Você pode implementar essa função mais tarde
    case 'Desserts':
      return _dessertsGrid(); // Você pode implementar essa função mais tarde
    default:
      return _burgerGrid();
  }
}

// Método para o grid de Burgers (o que você já tinha)
Widget _burgerGrid() {
  return GridView.extent(
    maxCrossAxisExtent: 200,
    childAspectRatio: 1 / 1.2,
    children: [
      _item(
        image: 'assets/items/1.png', 
        title: 'Original Burger', 
        price: '\$5.99', 
        quantity: _getQuantityFor('Original Burger'),
        item: '11 item', 
        onAdd: () {
          addToOrder('assets/items/1.png', 'Original Burger', 5.99);
        }, 
        onRemove: () {
          removeFromOrder('Original Burger');
        }
      ),
      _item(image: 'assets/items/2.png', title: 'Double Burger', price: '\$10.99', quantity: _getQuantityFor('Double Burger'), item: '10 item', onAdd: () {
        addToOrder('assets/items/2.png', 'Double Burger', 10.99);
      }, onRemove: () {
        removeFromOrder('Double Burger');
      }),
      _item(image: 'assets/items/3.png', title: 'Cheese Burger', price: '\$6.99', quantity: _getQuantityFor('Cheese Burger'), item: '7 item', onAdd: () {
        addToOrder('assets/items/3.png', 'Cheese Burger', 6.99);
      }, onRemove: () {
        removeFromOrder('Cheese Burger');
      }),
      _item(image: 'assets/items/4.png', title: 'Double Cheese Burger', price: '\$12.99',quantity: _getQuantityFor('Double Cheese Burger'), item: '20 item', onAdd: () {
        addToOrder('assets/items/4.png', 'Double Cheese Burger', 12.99);
      }, onRemove: () {
        removeFromOrder('Double Cheese Burger');
      }),
      _item(image: 'assets/items/5.png', title: 'Spicy Burger', price: '\$7.39', quantity: _getQuantityFor('Spicy Burger'), item: '12 item', onAdd: () {
        addToOrder('assets/items/5.png', 'Spicy Burger', 7.39);
      }, onRemove: () {
        removeFromOrder('Spicy Burger');
      }),
      _item(image: 'assets/items/6.png', title: 'Special Black Burger', price: '\$7.39',quantity: _getQuantityFor('Special Black Burger'), item: '39 item', onAdd: () {
        addToOrder('assets/items/6.png', 'Special Black Burger', 7.39);
      }, onRemove: () {
        removeFromOrder('Special Black Burger');
      }),
      _item(image: 'assets/items/7.png', title: 'Special Cheese Burger', price: '\$8.00', quantity: _getQuantityFor('Special Cheese Burger'), item: '2 item', onAdd: () {
        addToOrder('assets/items/7.png', 'Special Cheese Burger', 8.00);
      }, onRemove: () {
        removeFromOrder('Special Cheese Burger');
      }),
      _item(image: 'assets/items/8.png', title: 'Jumbo Cheese Burger', price: '\$15.99',quantity: _getQuantityFor('Jumbo Cheese Burger'), item: '2 item', onAdd: () {
        addToOrder('assets/items/8.png', 'Jumbo Cheese Burger', 15.99);
      }, onRemove: () {
        removeFromOrder('Jumbo Cheese Burger');
      }),
      _item(image: 'assets/items/9.png', title: 'Spicy Burger', price: '\$7.39',quantity: _getQuantityFor('Spicy Burger') ,item: '12 item', onAdd: () {
        addToOrder('assets/items/9.png', 'Spicy Burger', 7.39);
      }, onRemove: () {
        removeFromOrder('Spicy Burger');
      }),
      // ... resto dos burgers que você já tinha
      _item(
        image: 'assets/items/3.png', 
        title: 'Cheese Burger', 
        price: '\$6.99', 
        quantity: _getQuantityFor('Cheese Burger'), 
        item: '7 item', 
        onAdd: () {
          addToOrder('assets/items/3.png', 'Cheese Burger', 6.99);
        }, 
        onRemove: () {
          removeFromOrder('Cheese Burger');
        }
      ),
      // ... adicione os outros burgers
    ],
  );
}

// Para os grids que você ainda não implementou
Widget _noodlesGrid() {
  return Center(
    child: Text(
      'Noodles em breve!',
      style: TextStyle(color: Colors.white, fontSize: 18),
    ),
  );
}

Widget _dessertsGrid() {
  return Center(
    child: Text(
      'Sobremesas em breve!',
      style: TextStyle(color: Colors.white, fontSize: 18),
    ),
  );
}
}


