// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/config.dart';
import 'package:flutter_app/model/userplantphoto_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PhotoService{
  static Future<SharedPreferences> instance = SharedPreferences.getInstance();

  static Future<String> getUserId() async {
    final SharedPreferences prefs = await instance;
    return prefs.getString('id')!;
  }
  
  static dailyPhoto(String userPlantId, File? image) async {
    var url = Uri.parse("${Routes.url}dailyPhoto/$userPlantId");
    var request = http.MultipartRequest('POST', url);

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

  static retakePhoto(String photoId, File? image) async {
    var url = Uri.parse("${Routes.url}retakePhoto/$photoId");
    var request = http.MultipartRequest('PUT', url);

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

  static Future<List<UserPlantPhoto>> getUserPhotos() async {
    final userId = await getUserId();
    var url = Uri.parse("${Routes.url}getUserPhotos/$userId");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);

      return (jsonResponse['photos'] as List).map((photo) => UserPlantPhoto.fromJson(photo)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<List<UserPlantPhoto>> getPendingPlantPhotos({String query = ''}) async {
    var url = Uri.parse("${Routes.url}getPendingPhotos?search=$query");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);

      return (jsonResponse['photos'] as List).map((photo) => UserPlantPhoto.fromJson(photo)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static verifyPhoto(var id) async {
    var url = Uri.parse("${Routes.url}verifyPhoto/$id");

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

  static rejectPhoto(var id, String reason) async {
    var url = Uri.parse("${Routes.url}rejectPhoto/$id");

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
}