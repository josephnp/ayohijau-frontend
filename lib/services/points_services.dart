// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/config.dart';
import 'package:flutter_app/model/points_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PointService{
  static Future<SharedPreferences> instance = SharedPreferences.getInstance();
  static ValueNotifier<int> pointsNotifier = ValueNotifier<int>(0);

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await instance;
    return prefs.getString('id')!;
  }

  static Future<void> initializePoints() async {
    final SharedPreferences prefs = await instance;
    pointsNotifier.value = prefs.getInt('point') ?? 0;
  }

  static Future<List<PointsHistory>> getPointsHistory() async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}getPointsHistory/$userId");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);

      return (jsonResponse['pointsHistory'] as List).map((pointsHistory) => PointsHistory.fromJson(pointsHistory)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<List<PointsHistory>> getPendingPoints() async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}getPendingPoints/$userId");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);

      return (jsonResponse['pointsHistory'] as List).map((pointsHistory) => PointsHistory.fromJson(pointsHistory)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<List<PointsHistory>> getAllPendingPoints({String query = ''}) async {
    var url = Uri.parse("${Routes.url}getAllPendingPoints?search=$query");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);

      return (jsonResponse['pointsHistory'] as List).map((pointsHistory) => PointsHistory.fromJson(pointsHistory)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static changePoint(String userId, Map<String, dynamic> data) async {
    var url = Uri.parse("${Routes.url}pointChange/$userId");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data)
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        print(responseBody);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('point', responseBody['pointChange']['point']);
        pointsNotifier.value = responseBody['pointChange']['point'];
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static requestRedeem(String userId, Map<String, dynamic> data) async {
    var url = Uri.parse("${Routes.url}requestRedeem/$userId");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data)
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        print(responseBody);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('point', responseBody['pointChange']['point']);
        pointsNotifier.value = responseBody['pointChange']['point'];
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static rejectRedeem(String id, Map<String, dynamic> data) async {
    var url = Uri.parse("${Routes.url}rejectRedeem/$id");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data)
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        print(responseBody);
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static confirmRedeem(String id, String desc) async {
    var url = Uri.parse("${Routes.url}confirmRedeem/$id");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"desc": desc})
      );

      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        print(responseBody);
      } else {
        print("Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}