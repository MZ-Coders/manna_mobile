import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common/cart_service.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/common_widget/round_icon_button.dart';
import 'package:dribbble_challenge/src/recipes/domain/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../more/my_order_view.dart';

import 'package:dribbble_challenge/src/core/theme/app_colors.dart';

class FoodItemDetailsView extends StatefulWidget {
  final Map<String, dynamic> foodDetails;
  // final Recipe recipe2;
  
  const FoodItemDetailsView({super.key, required this.foodDetails});

  @override
  State<FoodItemDetailsView> createState() => _FoodItemDetailsViewState();
}

class _FoodItemDetailsViewState extends State<FoodItemDetailsView> {
  double price = 16;
  int qty = 1;
  bool isFav = false;
  bool isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    this.price = widget.foodDetails["price"];
    
    // Verificar se é tela larga (web/desktop) ou estreita (mobile)
    bool isWideScreen = media.width > 450;
    bool isMediumScreen = media.width > 400 && media.width <= 450;
    
    // Definir tamanhos baseados no tipo de tela
    double contentMaxWidth = isWideScreen ? 600 : media.width;
    double imageHeight = isWideScreen ? 400 : 
                    isMediumScreen ? media.width * 0.8 : 
                    media.width;
    
    return Scaffold(
      backgroundColor: TColor.primaryText,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Imagem de fundo
          Container(
  width: media.width,
  height: imageHeight,
  child: Image.network(
    widget.foodDetails["image"],
    width: media.width,
    height: imageHeight,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        width: media.width,
        height: imageHeight,
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                    : null,
                color: TColor.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "Loading image...",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: media.width,
        height: imageHeight,
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: TColor.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              "Unable to load image",
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    },
  ),
),
          
          // Gradiente sobre a imagem
          Container(
            width: media.width,
            height: imageHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              ),
            ),
          ),
          
          // Conteúdo principal
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: imageHeight - 60,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 35),
                                
                                // Nome do item
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Text(
                                    widget.foodDetails["name"],
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: isWideScreen ? 26 : 22,
                                      fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Avaliações e preço
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: isWideScreen 
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            _buildRatingWidget(),
                                            _buildPriceWidget(),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildRatingWidget(),
                                            _buildPriceWidget(),
                                          ],
                                        ),
                                ),
                                const SizedBox(height: 15),
                                
                                // Descrição
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Text(
                                    AppLocalizations.of(context).description,
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: isWideScreen ? 16 : 14,
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Text(
                                    widget.foodDetails["description"],
                                    style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: isWideScreen ? 14 : 12
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Divisor
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Divider(
                                    color: TColor.secondaryText.withOpacity(0.4),
                                    height: 1,
                                  )
                                ),
                                const SizedBox(height: 20),
                                
                                // Número de porções
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).numberPortions,
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: isWideScreen ? 16 : 14,
                                          fontWeight: FontWeight.w700
                                        ),
                                      ),
                                      const Spacer(),
                                      _buildQuantitySelector(),
                                    ],
                                  ),
                                ),
                                
                                // Preço total e botão de adicionar ao carrinho
                                isWideScreen 
                                    ? _buildWideScreenTotalPriceWidget()
                                    : _buildMobileScreenTotalPriceWidget(media),
                                
                                const SizedBox(height: 20),
                              ]
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      
                      // Botão de favoritos
                      Container(
                        height: imageHeight - 20,
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.only(right: 4),
                        child: InkWell(
                          onTap: () {
                            isFav = !isFav;
                            setState(() {});
                          },
                          child: Image.asset(
                            isFav ? "assets/img/favorites_btn.png" : "assets/img/favorites_btn_2.png",
                            width: 70,
                            height: 70
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Barra de navegação superior
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 15),
                Container(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Image.asset(
                            "assets/img/btn_back.png",
                            width: 20,
                            height: 20,
                            color: TColor.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrderView()
                              )
                            );
                          },
                          icon: Image.asset(
                            "assets/img/shopping_cart.png",
                            width: 25,
                            height: 25,
                            color: TColor.white,
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
      ),
    );
  }
  
  // Widget para exibir as avaliações
  Widget _buildRatingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IgnorePointer(
          ignoring: true,
          child: RatingBar.builder(
            initialRating: 4,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 20,
            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: TColor.primary,
            ),
            onRatingUpdate: (rating) {
              print(rating);
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          " 4 Star Ratings",
          style: TextStyle(
            color: TColor.primary,
            fontSize: 11,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
  
  // Widget para exibir o preço

Widget _buildPriceWidget() {
  bool isOnPromotion = widget.foodDetails["is_on_promotion"] == true;
  double regularPrice = widget.foodDetails["regular_price"]?.toDouble() ?? price;
  double currentPrice = price;
  
  // Calcular porcentagem de desconto
  double discountPercent = 0;
  if (isOnPromotion && regularPrice > currentPrice) {
    discountPercent = ((regularPrice - currentPrice) / regularPrice) * 100;
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      // Badge de promoção
      if (isOnPromotion)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${AppLocalizations.of(context).promotion} -${discountPercent.toStringAsFixed(0)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      
      // Preços
      if (isOnPromotion && regularPrice > currentPrice) ...[
        // Preço original riscado
        Text(
          "${regularPrice.toStringAsFixed(2)} MZN",
          style: TextStyle(
            color: TColor.secondaryText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const SizedBox(height: 4),
      ],
      
      // Preço atual
      Text(
        "${currentPrice.toStringAsFixed(2)} MZN",
        style: TextStyle(
          color: isOnPromotion ? Colors.red : TColor.primaryText,
          fontSize: 31,
          fontWeight: FontWeight.w700
        ),
      ),
      const SizedBox(height: 4),
      Text(
        AppLocalizations.of(context).perPortion,
        style: TextStyle(
          color: TColor.primaryText,
          fontSize: 11,
          fontWeight: FontWeight.w500
        ),
      ),
    ],
  );
}
  // Widget para o seletor de quantidade
  Widget _buildQuantitySelector() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            qty = qty - 1;
            if (qty < 1) {
              qty = 1;
            }
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: BorderRadius.circular(12.5)
            ),
            child: Text(
              "-",
              style: TextStyle(
                color: TColor.white,
                fontSize: 14,
                fontWeight: FontWeight.w700
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: TColor.primary),
            borderRadius: BorderRadius.circular(12.5)
          ),
          child: Text(
            qty.toString(),
            style: TextStyle(
              color: TColor.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            qty = qty + 1;
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: BorderRadius.circular(12.5)
            ),
            child: Text(
              "+",
              style: TextStyle(
                color: TColor.white,
                fontSize: 14,
                fontWeight: FontWeight.w700
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Layout do preço total para telas largas (web/desktop)
  Widget _buildWideScreenTotalPriceWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4)
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).totalPrice,
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${(price * qty).toStringAsFixed(2)} MZN",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.w700
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 40,
                child: RoundIconButton(
                  title: isAddingToCart ? AppLocalizations.of(context).adding : AppLocalizations.of(context).addToCart,
                  icon: isAddingToCart ? "assets/img/shopping_add.png" : "assets/img/shopping_add.png",
                  color: isAddingToCart ? TColor.secondaryText : TColor.primary,
                  onPressed: isAddingToCart ? (){} : () async {
                    setState(() {
                      isAddingToCart = true;
                    });
                    
                    // Simular delay para melhor UX
                    await Future.delayed(const Duration(milliseconds: 800));
                    
                    CartService.addToCart(widget.foodDetails["name"], qty, price, widget.foodDetails["id"]);
                    
                    setState(() {
                      isAddingToCart = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text("${widget.foodDetails["name"]} ${AppLocalizations.of(context).addedToCart}"),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                ),
              ),
              const SizedBox(width: 15),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrderView()
                    )
                  );
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2)
                      )
                    ]
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/img/shopping_cart.png",
                    width: 20,
                    height: 20,
                    color: TColor.primary
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Layout do preço total para telas móveis
  Widget _buildMobileScreenTotalPriceWidget(Size media) {
    return SizedBox(
      height: media.width < 400 ? 180 : 220,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: media.width < 400 ? media.width * 0.2 : media.width * 0.25,
            height: 160,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(35),
                bottomRight: Radius.circular(35)
              ),
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left: 10,
                    right: 20
                  ),
                  width: media.width - 80,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      bottomLeft: Radius.circular(35),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4)
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Total Price",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "${(price * qty).toStringAsFixed(2)} MZN",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 21,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
  width: 130,
  height: 25,
  child: RoundIconButton(
    title: isAddingToCart ? "Adding..." : AppLocalizations.of(context).addToCart,
    icon: isAddingToCart ? "assets/img/shopping_add.png" : "assets/img/shopping_add.png",
    color: isAddingToCart ? TColor.secondaryText : TColor.primary,
    onPressed: isAddingToCart ? (){} : () async {
      setState(() {
        isAddingToCart = true;
      });
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      CartService.addToCart(widget.foodDetails["name"], qty, price, widget.foodDetails["id"]);
      
      setState(() {
        isAddingToCart = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text("${widget.foodDetails["name"]} ${AppLocalizations.of(context).addedToCart}")),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  ),
)
                    ],
                  )
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyOrderView()
                      )
                    );
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2)
                        )
                      ]
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/img/shopping_cart.png",
                      width: 20,
                      height: 20,
                      color: TColor.primary
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}