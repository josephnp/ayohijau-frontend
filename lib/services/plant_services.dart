// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/config.dart';
import 'package:flutter_app/model/plant_model.dart';
import 'package:http/http.dart' as http;

class PlantService{
  static createPlant(Map<String, dynamic> data, File? image) async {
    var url = Uri.parse("${Routes.url}addPlant");
    var request = http.MultipartRequest('POST', url);

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
  
  static Future<List<Plant>> getPlants({String query = ''}) async {
    var url = Uri.parse("${Routes.url}getPlants?name=$query");

    try {
      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      
      return (jsonResponse['plants'] as List).map((plant) => Plant.fromJson(plant)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
  
  static updatePlant(var id, Map<String, dynamic> data, File? image, String? imageUrl) async {
    var url = Uri.parse("${Routes.url}editPlant/$id");
    var request = http.MultipartRequest('PUT', url);

    print("$image & ${imageUrl!}");

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (image != null) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile('image', stream, length, filename: image.path.split('/').last);

      request.files.add(multipartFile);
    } else {
      request.fields['image'] = imageUrl;
    }

    final response = await request.send();
    
    if (response.statusCode == 200) {
      print(jsonDecode(await response.stream.bytesToString()));
    } else {
      print("Failed");
    }
  }
}