// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/config.dart';
import 'package:flutter_app/model/userplant_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserPlantService{
  static Future<SharedPreferences> instance = SharedPreferences.getInstance();

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await instance;
    return prefs.getString('id')!;
  }

  static createUserPlant(Map<String, dynamic> data) async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}addUserPlant/$userId");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data)
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

  static Future<List<UserPlant>> getUserPlants() async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}getUserPlant/$userId");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);
      
      return (jsonResponse['plants'] as List).map((plant) => UserPlant.fromJson(plant)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}