// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService{
  static Future<SharedPreferences> instance = SharedPreferences.getInstance();

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await instance;
    return prefs.getString('id')!;
  }

  static Future<String> register(Map<String, dynamic> data) async {
    var url = Uri.parse("${Routes.url}registration");

    try {
      final response = await http.post(
        url,  
        headers: {"Content-Type": "application/json"},
        body:jsonEncode(data)
      );
      
      if (response.statusCode == 200) {
        return "success";
      } else {
        var responseBody = jsonDecode(response.body);
        return responseBody['status'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> login(Map<String, dynamic> data) async {
    var url = Uri.parse("${Routes.url}login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body:jsonEncode(data)
      );
      
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseBody['token']);
        await prefs.setString('id', responseBody['id'].toString());
        await prefs.setString('name', responseBody['name'] ?? "");
        await prefs.setString('username', responseBody['username']);
        await prefs.setString('email', responseBody['email']);
        await prefs.setString('password', responseBody['password']);
        await prefs.setString('address', responseBody['address'] ?? "");
        await prefs.setString('phoneNumber', responseBody['phoneNumber'] ?? "");
        await prefs.setInt('point', responseBody['point'] ?? 0);
        await prefs.setString('role', responseBody['role']);

        print(responseBody);
        return responseBody['role'];
      } else {
        var responseBody = jsonDecode(response.body);
        return responseBody['status'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  static validateUserData(Map<String, dynamic> data) async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}validateUpdateUser/$userId");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body:jsonEncode(data)
      );

      var responseBody = jsonDecode(response.body);
      return responseBody['status'];
    } catch (e) {
      return e.toString();
    }
  }

  static updateUser(Map<String, dynamic> data) async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}updateUser/$userId");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body:jsonEncode(data)
      );
      
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', data['name']);
        await prefs.setString('username', data['username']);
        await prefs.setString('email', data['email']);
        await prefs.setString('password', data['password']);
        await prefs.setString('address', data['address']);
        await prefs.setString('phoneNumber', data['phoneNumber']);

        print(responseBody);
    } else {
        var responseBody = jsonDecode(response.body);
        return responseBody['status'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  static logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return;
  }
}