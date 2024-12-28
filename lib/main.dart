// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/admin/admin.dart';
import 'package:flutter_app/login.dart';
import 'package:flutter_app/user/navbar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? role = prefs.getString('role');
  
  print('Token $token');
  runApp(MyApp(token: token, role: role));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? role;

  const MyApp({
    super.key,
    required this.token,
    required this.role
  });

  @override
  Widget build(BuildContext context) {
    if (token != null) {
      bool isExpired = JwtDecoder.isExpired(token!);
      print('Token is expired: $isExpired');
    } else {
      print('Token is null');
    }
    
    return MaterialApp(
      home: token != null && !JwtDecoder.isExpired(token!)
        ? role == "Admin"
          ? const Admin()
          : const NavBar(initIndex: 0)
        : const Login(),
    );
  }
}