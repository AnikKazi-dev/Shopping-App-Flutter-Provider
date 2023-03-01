import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/orders.dart' show Orders;
import 'package:shopping_app/widgets/app_drawer.dart';
import 'package:shopping_app/widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = "/order-screen";

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

@override
class _OrderScreenState extends State<OrderScreen> {
  //var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return Center(
                child: Text("Nothing to Show"),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, _) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (BuildContext context, int index) =>
                      OrderItem(orderData.orders[index]),
                ),
              );
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
