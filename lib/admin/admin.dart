import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/admin/delivery.dart';
import 'package:flutter_app/admin/verifyphotos.dart';
import 'package:flutter_app/admin/verifyredeem.dart';
import 'package:flutter_app/assets/button_admin.dart';
import 'package:flutter_app/admin/manageplants.dart';
import 'package:flutter_app/assets/custom_fablocation.dart';
import 'package:flutter_app/login.dart';
import 'package:flutter_app/services/user_services.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  
  Future<bool> onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Admin Page'),
          backgroundColor: Colors.green[300],
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonAdmin(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagePlants()));
                },
                child: const Text('Manage Plants'),
              ),
              const SizedBox(height: 18,),
              ButtonAdmin(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Delivery()));
                },
                child: const Text('Set Delivery'),
              ),
              const SizedBox(height: 18,),
              ButtonAdmin(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyPhotos()));
                },
                child: const Text('Verify Photos'),
              ),
              const SizedBox(height: 18,),
              ButtonAdmin(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyRedeem()));
                },
                child: const Text('Redeem Point'),
              ),
            ],
          ),
        ),
        floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            minimumSize: const Size(10, 50),
            textStyle: const TextStyle(
              fontSize: 16
            )
          ),
          onPressed: () async {
            await UserService.logout();
            Navigator.push(context, MaterialPageRoute(builder:(context) => const Login()));
          },
          child: const Text("Exit")
        ),
        floatingActionButtonLocation: CustomFloatingActionButtonLocation(
          FloatingActionButtonLocation.centerDocked,
          0, -20
        ),
      )
    );
  }
}