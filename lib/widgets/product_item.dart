import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/auth.dart';
import 'package:shopping_app/providers/cart.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    //Another Approach is: Consumer<product>(builder(context,product, child)=>|widget| , child: ,... ),
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          //we can use InkWell as well
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage(
                "assets/images/product-placeholder.png",
              ),
              image: NetworkImage(product.imageUrl),
            ),
          ),
        ),
        footer: GridTileBar(
          leading: IconButton(
            icon: product.isFavorite
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
            color: Theme.of(context).accentColor,
            onPressed: () {
              product.toggleIsFavorite(auth.token, auth.userId);
            },
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Item added to cart"),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
