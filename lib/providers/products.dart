import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String token;
  final String userId;
  Products(this.token, this.userId, this._items);
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItem {
    return _items.where((element) => element.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // var url = Uri.https(
    //   "shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app",
    //   "/products.json",
    //   {
    //     'auth': token,
    //     'orderBy': 'creatorId',
    //     'equalTo': userId,
    //   },
    // );
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$token&$filterString');

    try {
      final response = await http.get(url);
      //print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }
      url = Uri.https(
          "shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app",
          "/userFavourites/$userId.json",
          {'auth': token});
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productData["title"],
            price: productData["price"],
            description: productData["description"],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
            imageUrl: productData["imageUrl"],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.https(
        "shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app",
        "/products.json",
        {'auth': token});

    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "price": product.price,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
          "creatorId": userId,
        }),
      );

      final newProduct = Product(
        id: json.decode(response.body)["name"],
        //id: DateTime.now().toString(),
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // _items.insert(0,newProduct); //insert bigging of the list
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);

    if (productIndex >= 0) {
      var url = Uri.https(
          "shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app",
          "/products/$id.json",
          {'auth': token});
      await http.patch(
        url,
        body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "price": newProduct.price,
          "imageUrl": newProduct.imageUrl,
          "isFavorite": newProduct.isFavorite,
        }),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> removeProduct(String id) async {
    var url = Uri.https(
        "shop-app-faeb9-default-rtdb.asia-southeast1.firebasedatabase.app",
        "/products/$id.json",
        {'auth': token});

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    final response = await http.delete(url);

    _items.removeAt(existingProductIndex);
    notifyListeners();

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
    existingProduct.dispose();

    //_items.removeWhere((element) => element.id == id);
  }
}
