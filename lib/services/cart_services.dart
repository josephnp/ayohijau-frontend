// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/config.dart';
import 'package:flutter_app/model/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartService{
  static Future<SharedPreferences> instance = SharedPreferences.getInstance();

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await instance;
    return prefs.getString('id')!;
  }

  static addItemToCart(String plantId) async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}addItemToCart");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body:jsonEncode({
          "userId": userId,
          "plantId": plantId
        })
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body.toString()));
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static removeItemFromCart(String plantId) async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}removeItemFromCart");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body:jsonEncode({
          "userId": userId,
          "plantId": plantId
        })
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body.toString()));
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<Cart> getCart() async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}getCart/$userId");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);

      print(jsonResponse);
      return Cart.fromJson(jsonResponse['cart']);
    } catch (e) {
      rethrow;
    }
  }

  static resetItems() async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}resetItems/$userId");
    print("reset cart");

    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        print(jsonDecode(response.body.toString()));
      } else {
        print("Failed");
      }
    } catch (e) {
      rethrow;
    }
  }
}