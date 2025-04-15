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
                title: 'Lorem Restourant',
                subTitle: '20 October 2022',
                action: _search(),
              ),
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _itemTab(
                      icon: 'icons/icon-burger.png',
                      title: 'Burger',
                      isActive: true,
                    ),
                    _itemTab(
                      icon: 'icons/icon-noodles.png',
                      title: 'Noodles',
                      isActive: false,
                    ),
                    _itemTab(
                      icon: 'icons/icon-drinks.png',
                      title: 'Drinks',
                      isActive: false,
                    ),
                    _itemTab(
                      icon: 'icons/icon-desserts.png',
                      title: 'Desserts',
                      isActive: false,
                    )
                  ],
                ),
              ),
             Expanded(
  child: GridView.extent(
    maxCrossAxisExtent: 200, // largura máxima de cada item
    childAspectRatio: 1 / 1.2,
    children: [
      _item(
        image: 'items/1.png', 
        title: 'Original Burger', 
        price: '\$5.99', 
        quantity: _getQuantityFor('Original Burger'),
        item: '11 item', 
        onAdd: () {
        addToOrder('items/1.png', 'Original Burger', 5.99);
      }, onRemove: () {
        removeFromOrder('Original Burger');
      }),
      _item(image: 'items/2.png', title: 'Double Burger', price: '\$10.99', quantity: _getQuantityFor('Double Burger'), item: '10 item', onAdd: () {
        addToOrder('items/2.png', 'Double Burger', 10.99);
      }, onRemove: () {
        removeFromOrder('Double Burger');
      }),
      _item(image: 'items/3.png', title: 'Cheese Burger', price: '\$6.99', quantity: _getQuantityFor('Cheese Burger'), item: '7 item', onAdd: () {
        addToOrder('items/3.png', 'Cheese Burger', 6.99);
      }, onRemove: () {
        removeFromOrder('Cheese Burger');
      }),
      _item(image: 'items/4.png', title: 'Double Cheese Burger', price: '\$12.99',quantity: _getQuantityFor('Double Cheese Burger'), item: '20 item', onAdd: () {
        addToOrder('items/4.png', 'Double Cheese Burger', 12.99);
      }, onRemove: () {
        removeFromOrder('Double Cheese Burger');
      }),
      _item(image: 'items/5.png', title: 'Spicy Burger', price: '\$7.39', quantity: _getQuantityFor('Spicy Burger'), item: '12 item', onAdd: () {
        addToOrder('items/5.png', 'Spicy Burger', 7.39);
      }, onRemove: () {
        removeFromOrder('Spicy Burger');
      }),
      _item(image: 'items/6.png', title: 'Special Black Burger', price: '\$7.39',quantity: _getQuantityFor('Special Black Burger'), item: '39 item', onAdd: () {
        addToOrder('items/6.png', 'Special Black Burger', 7.39);
      }, onRemove: () {
        removeFromOrder('Special Black Burger');
      }),
      _item(image: 'items/7.png', title: 'Special Cheese Burger', price: '\$8.00', quantity: _getQuantityFor('Special Cheese Burger'), item: '2 item', onAdd: () {
        addToOrder('items/7.png', 'Special Cheese Burger', 8.00);
      }, onRemove: () {
        removeFromOrder('Special Cheese Burger');
      }),
      _item(image: 'items/8.png', title: 'Jumbo Cheese Burger', price: '\$15.99',quantity: _getQuantityFor('Jumbo Cheese Burger'), item: '2 item', onAdd: () {
        addToOrder('items/8.png', 'Jumbo Cheese Burger', 15.99);
      }, onRemove: () {
        removeFromOrder('Jumbo Cheese Burger');
      }),
      _item(image: 'items/9.png', title: 'Spicy Burger', price: '\$7.39',quantity: _getQuantityFor('Spicy Burger') ,item: '12 item', onAdd: () {
        addToOrder('items/9.png', 'Spicy Burger', 7.39);
      }, onRemove: () {
        removeFromOrder('Spicy Burger');
      }),
    ],
  ),
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
Expanded(
  child: Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: const Color(0xff1f2029),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sub Total',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              '\$${calculateSubtotal().toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tax',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              '\$${calculateTax(calculateSubtotal()).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          height: 2,
          width: double.infinity,
          color: Colors.white,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              '\$${calculateTotal(calculateSubtotal(), calculateTax(calculateSubtotal())).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepOrange,
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
),
            ],
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
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xff1f2029),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Text(
            '$qty x',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
      color: const Color(0xff1f2029),
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
          style: const TextStyle(
            color: Colors.white,
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
              style: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 20,
              ),
            ),
            Text(
              item,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  onRemove();
                },
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
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



  Widget _itemTab(
      {required String icon, required String title, required bool isActive}) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 26),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xff1f2029),
        border: isActive
            ? Border.all(color: Colors.deepOrangeAccent, width: 3)
            : Border.all(color: const Color(0xff1f2029), width: 3),
      ),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 38,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
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
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subTitle,
              style: const TextStyle(
                color: Colors.white54,
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
          color: const Color(0xff1f2029),
        ),
        child: Row(
          children: const [
            Icon(
              Icons.search,
              color: Colors.white54,
            ),
            SizedBox(width: 10),
            Text(
              'Search menu here...',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            )
          ],
        ));
  }
}
