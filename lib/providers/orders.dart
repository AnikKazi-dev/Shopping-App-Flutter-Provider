import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './cart.dart';
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String token;
  final String userId;
  Orders(this.token, this.userId, this._orders);

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    var url = Uri.https(
        "shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app",
        "/orders/$userId.json",
        {'auth': token});
    final response = await http.get(url);

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          dateTime: DateTime.parse(orderData["dateTime"]),
          products: (orderData["products"] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item["id"],
                  title: item["title"],
                  quantity: item["quantity"],
                  price: item["price"],
                ),
              )
              .toList(),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
  }

  Future<void> addOrders(List<CartItem> cartProducts, double total) async {
    var url = Uri.https(
        "shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app",
        "/orders/$userId.json",
        {'auth': token});
    var dateTime = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode({
        "amount": total,
        "dateTime": dateTime.toIso8601String(),
        "products": cartProducts
            .map((cp) => {
                  "id": cp.id,
                  "title": cp.title,
                  "quantity": cp.quantity,
                  "price": cp.price,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        products: cartProducts,
        dateTime: dateTime,
      ),
    );
    notifyListeners();
  }
}
