// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/config.dart';
import 'package:flutter_app/model/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService{
  static Future<SharedPreferences> instance = SharedPreferences.getInstance();

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await instance;
    return prefs.getString('id')!;
  }

  static Future<String> checkoutOrder(Map<String, List<String>> data) async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}checkoutOrder/$userId");
    print(data);

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data)
      );

      if (response.statusCode == 200) {
        print(jsonDecode(response.body.toString()));
        return "success";
      } else {
        var responseBody = jsonDecode(response.body);
        return responseBody['status'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  static Future<List<Order>> getOrderByUserId() async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}getOrder/$userId");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);
      // print(jsonResponse);

      return (jsonResponse['order'] as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<List<Order>> getAllPendingOrders({String query = ''}) async {
    var url = Uri.parse("${Routes.url}getPendingOrders?search=$query");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      
      return (jsonResponse['orders'] as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static cancelOrder(var id) async {
    var url = Uri.parse("${Routes.url}cancelOrder/$id");

    try {
      var response = await http.put(url);

      if (response.statusCode == 200) {
        print(jsonDecode(response.body.toString()));
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static payOrder(var id, Map<String, dynamic> data, File? image) async {
    var url = Uri.parse("${Routes.url}payOrder/$id");
    var request = http.MultipartRequest('PUT', url);

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (image != null) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile('image', stream, length, filename: image.path.split('/').last);

      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        print(jsonDecode(await response.stream.bytesToString()));
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }

  }

  static rejectOrder(var id, String reason) async {
    var url = Uri.parse("${Routes.url}rejectOrder/$id");

    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"reason": reason})
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

  static deliverOrder(var id, String link) async {
    var url = Uri.parse("${Routes.url}deliverOrder/$id");

    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"link": link})
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

  static confirmOrder(var id) async {
    var url = Uri.parse("${Routes.url}confirmOrder/$id");

    try {
      var response = await http.put(url);

      if (response.statusCode == 200) {
        print(jsonDecode(response.body.toString()));
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}