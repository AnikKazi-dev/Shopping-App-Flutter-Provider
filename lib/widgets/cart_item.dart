import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String productId;
  final String id;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.productId, this.id, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    //final cart = Provider.of<Cart>(context);
    return Dismissible(
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      child: Card(
        elevation: 10,
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: FittedBox(
                child: Text("৳${price}"),
              ),
            ),
            title: Text(title),
            subtitle: Text(
              "Total:৳ ${price * quantity}",
            ),
            trailing: Text("x${quantity}"),
          ),
        ),
      ),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              "Are you sure?",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content: Text("Do you really want to remove?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: Text(
                  "Yes",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
