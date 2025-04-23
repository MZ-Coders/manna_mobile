import 'dart:typed_data';

import 'package:dribbble_challenge/src/common/cart_service.dart';
import 'package:dribbble_challenge/src/common_widget/round_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:syncfusion_flutter_pdf/pdf.dart';

// import './../../pdf/web.dart' if (dart.library.html) './../../pdf/mobile.dart' as platform;
// import 'web.dart' if (dart.library.io) 'mobile.dart' as platform;
// import './../../pdf/web.dart';
import './../../pdf/mobile.dart' if (dart.library.html) './../../pdf/web.dart' as platform;
import 'checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  // List itemArr = [
  //   {"name": "Beef Burger", "qty": "2", "price": 16.0},
  //   {"name": "Classic Burger", "qty": "1", "price": 14.0},
  //   {"name": "Cheese Chicken Burger", "qty": "1", "price": 17.0},
  //   {"name": "Chicken Legs Basket", "qty": "1", "price": 15.0},
  //   {"name": "French Fires Large", "qty": "1", "price": 6.0}
  // ];

  List itemArr = CartService.getCartItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "My Order",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          "assets/img/shop_logo.png",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Manna Restaurant",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/img/rate.png",
                                width: 10,
                                height: 10,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "4.9",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.primary, fontSize: 12),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "(124 Ratings)",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Manna Restaurant",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.secondaryText, fontSize: 12),
                              ),
                              Text(
                                " . ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.primary, fontSize: 12),
                              ),
                              Text(
                                "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/img/location-pin.png",
                                width: 13,
                                height: 13,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  "Beira, Sofala, Mozambique",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: itemArr.length,
                  separatorBuilder: ((context, index) => Divider(
                        indent: 25,
                        endIndent: 25,
                        color: TColor.secondaryText.withOpacity(0.5),
                        height: 1,
                      )),
                  itemBuilder: ((context, index) {
                    var cObj = itemArr[index] as Map? ?? {};
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${cObj["name"].toString()} x${cObj["qty"].toString()}",
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "${cObj["price"].toString()}\MZN",
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text(
                        //   "Delivery Instructions",
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //       color: TColor.primaryText,
                        //       fontSize: 13,
                        //       fontWeight: FontWeight.w700),
                        // ),
                        // TextButton.icon(
                        //   onPressed: () {},
                        //   icon: Icon(Icons.add, color: TColor.primary),
                        //   label: Text(
                        //     "Add Notes",
                        //     style: TextStyle(
                        //         color: TColor.primary,
                        //         fontSize: 13,
                        //         fontWeight: FontWeight.w500),
                        //   ),
                        // )
                      ],
                    ),
                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                           "${CartService.getTotal().toStringAsFixed(2)}\MZN",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delivery Cost",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "0\MZN",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "${(CartService.getTotal() + 0).toStringAsFixed(2)}\MZN",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    RoundButton(
                        title: "Checkout",
                        onPressed: () {
                          _createPDFv2();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutView(),
                            ),
                          );
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

Future<void> _createPDFv2() async {
  final PdfDocument document = PdfDocument();
  final page = document.pages.add();

  // Logo (imagem opcional)
  final PdfBitmap logo = PdfBitmap(await _readImageData('assets/img/shop_logo.png'));
  page.graphics.drawImage(logo, Rect.fromLTWH(0, 0, 80, 80));

  // Nome da loja
  page.graphics.drawString(
    'Manna Restaurant',
    PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(90, 0, 500, 25),
  );

  // Endereço e categoria
  page.graphics.drawString(
    'Beira, Sofala, Mozambique',
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    bounds: Rect.fromLTWH(90, 25, 500, 20),
  );
  page.graphics.drawString(
    'Categoria: Restaurante',
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    bounds: Rect.fromLTWH(90, 45, 500, 20),
  );

  double currentY = 100;

  // Tabela de itens
  PdfGrid grid = PdfGrid();
  grid.columns.add(count: 3);
  grid.headers.add(1);

  PdfGridRow header = grid.headers[0];
  header.cells[0].value = 'Produto';
  header.cells[1].value = 'Qtd';
  header.cells[2].value = 'Preço';

  // Exemplo estático. Substitua por itemArr do seu app
  List<Map<String, dynamic>> items = CartService.getCartItems();

  print("Lista de Items "+items.toString());

  for (var item in items) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = item['name'];
    row.cells[1].value = "${item['qty']}";
    row.cells[2].value = "${(double.parse(item['price'].toString()) * double.parse(item['qty'].toString())).toStringAsFixed(2)} MZN";
  }

  grid.style = PdfGridStyle(
    font: PdfStandardFont(PdfFontFamily.helvetica, 12),
    cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
  );

  grid.draw(
    page: page,
    bounds: Rect.fromLTWH(0, currentY, page.getClientSize().width, 0),
  );

  currentY += 20 + (items.length * 25); // Ajustar para após a tabela

  // Subtotal e total
  double subTotal = items.fold(0, (sum, item) => sum + item['price']);
  double delivery = 0;
  double total = subTotal + delivery;

  page.graphics.drawString(
    'SubTotal: ${subTotal.toStringAsFixed(2)} MZN',
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    bounds: Rect.fromLTWH(300, currentY, 200, 20),
  );
  currentY += 20;

  page.graphics.drawString(
    'Custo de Entrega: ${delivery.toStringAsFixed(2)} MZN',
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    bounds: Rect.fromLTWH(300, currentY, 200, 20),
  );
  currentY += 20;

  page.graphics.drawString(
    'TOTAL: ${total.toStringAsFixed(2)} MZN',
    PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(300, currentY, 200, 25),
  );

  currentY += 40;

  // Rodapé
  page.graphics.drawString(
    'Obrigado pelo seu pedido!',
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    bounds: Rect.fromLTWH(0, currentY, page.getClientSize().width, 20),
  );

  page.graphics.drawString(
    'Data: ${DateTime.now().toLocal()}',
    PdfStandardFont(PdfFontFamily.helvetica, 10),
    bounds: Rect.fromLTWH(0, currentY + 20, 300, 15),
  );

  // Gerar e salvar
  List<int> bytes = await document.save();
  document.dispose();

  platform.saveAndLaunchFile(bytes, 'recibo_manna.pdf');

//  if(kIsWeb) {
//   await saveAndLaunchFileWeb(bytes, 'recibo_pedido.pdf');
//  }
//  else {
//   await saveAndLaunchFile(bytes, 'recibo_pedido.pdf');
//  }  
}


Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load(name);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

