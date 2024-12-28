// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_app/login.dart';
import 'package:flutter_app/services/points_services.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/user/history.dart';
import 'package:flutter_app/user/orderstatus.dart';
import 'package:flutter_app/user/photostatus.dart';
import 'package:flutter_app/user/redeem.dart';
import 'package:flutter_app/user/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late SharedPreferences prefs;
  String name = "";
  String username = "";
  
  @override
  void initState() {
    super.initState();
    initializeUser();
    PointService.initializePoints();
  }

  void initializeUser() async {
    prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name')!;
    username = prefs.getString('username')!;

    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 242),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 5),
          child: Column(
            children: [
              const Text('Profil User', style:
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
              const Divider(height: 40, color: Colors.green,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color.fromARGB(255, 69, 121, 19),
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama: $name', style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                          )
                        ),
                        Text('Username: $username', style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                          )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context) => const ProfileSettings(),));
                    },
                    icon: const Icon(
                      Icons.settings,
                      size: 28
                    )
                  )
                ],
              ),
              const Divider(height: 40, color: Colors.green,),
              Card(
                color: Colors.green,
                child: ValueListenableBuilder<int>(
                  valueListenable: PointService.pointsNotifier,
                  builder: (context, points, child) {
                    return ListTile(
                      title: Text('Poin Hijau: $points', style:
                        const TextStyle(
                          color: Colors.white
                        )
                      ),
                    );
                  }
                )
              ),
              const SizedBox(height: 14,),
              const Divider(height: 16, color: Colors.green,),
              ListTile(
                title: const Text('Status Pemesanan'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => const OrderStatus(),));
                },
              ),
              const Divider(height: 16, color: Colors.green,),
              ListTile(
                title: const Text('Status Verifikasi Foto'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => const PhotoStatus(),));
                },
              ),
              const Divider(height: 16, color: Colors.green,),
              ListTile(
                title: const Text('Redeem Poin'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => const RedeemPoints(),));
                },
              ),
              const Divider(height: 16, color: Colors.green,),
              ListTile(
                title: const Text('Riwayat Poin'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const History()));
                },
              ),
              const Divider(height: 16, color: Colors.green,),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await UserService.logout();
          Navigator.push(context, MaterialPageRoute(builder:(context) => const Login(),));
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.red),
          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 32, vertical: 4)),
          minimumSize: MaterialStatePropertyAll(Size(80, 50))
        ),
        child: const Text('Logout', style:
          TextStyle(
            color: Colors.white,
            fontSize: 16
          )
        ),
      ),
    );
  }
}