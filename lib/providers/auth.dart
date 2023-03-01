import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shopping_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = "";
  DateTime _expiryDate = DateTime.utc(0, 0, 0);
  String _userId = "";
  Timer _authTimer = Timer(Duration(seconds: 0), () {});

  bool get isAuth {
    return (token != "");
  }

  String get token {
    if (_expiryDate != DateTime.utc(0, 0, 0) &&
        (_expiryDate.isAfter(DateTime.now())) &&
        _token != "") {
      return _token;
    }
    return "";
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSecment) async {
    final url = Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:$urlSecment',
        {'key': 'AIzaSyB1GzZucvvVhelIL6Hx7GhdfuSXwrRPbCg'});

    try {
      final response = await http.post(
        url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );
      var responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      //print(_token);
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );
      //print("......................"+_expiryDate.toString());
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String(),
      });

      prefs.setString("userData", userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("userData")) {
      return false;
    }

    final extractedUserData = json.decode(prefs.getString("userData") as String)
        as Map<String, dynamic>;

    final expiryDate =
        DateTime.parse(extractedUserData["expiryDate"] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData["token"] as String;
    _userId = extractedUserData["userId"] as String;
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> logout() async {
    _token = "";
    _userId = "";
    _expiryDate = DateTime.utc(0, 0, 0);
    if (_authTimer != (Timer(Duration(seconds: 0), () {}))) {
      _authTimer.cancel();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove("userData");
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != 0) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
