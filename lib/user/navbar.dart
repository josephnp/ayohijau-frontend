import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/user/home.dart';
import 'package:flutter_app/user/plantphoto.dart';
import 'package:flutter_app/user/informations.dart';
import 'package:flutter_app/user/profile.dart';
import 'package:flutter_app/user/shop.dart';

class NavBar extends StatefulWidget {
  final int initIndex;

  const NavBar({
    super.key,
    required this.initIndex,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int widgetIndex;

  @override
  void initState(){
    super.initState();
    widgetIndex = widget.initIndex;
  }

  static const List<Widget> widgets = <Widget>[
    Home(),
    PlantStore(),
    PlantPhoto(),
    Informations(),
    Profile()
  ];

  void switchWidget(int index) {
    setState(() {
      widgetIndex = index;
    });
  }

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
        body: IndexedStack(
          index: widgetIndex,
          children: widgets,
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(255, 69, 121, 19),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.home,
                  size: 32
                ),
                color: widgetIndex == 0 ? Colors.lightGreenAccent : Colors.white,
                onPressed: () => switchWidget(0),
              ),
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart,
                  size: 32
                ),
                color: widgetIndex == 1 ? Colors.lightGreenAccent : Colors.white,
                onPressed: () => switchWidget(1),
              ),
              IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 32
                ),
                color: widgetIndex == 2 ? Colors.lightGreenAccent : Colors.white,
                onPressed: () => switchWidget(2),
              ),
              // const SizedBox(width: 80),
              IconButton(
                icon: const Icon(
                  Icons.local_florist,
                  size: 32
                ),
                color: widgetIndex == 3 ? Colors.lightGreenAccent : Colors.white,
                onPressed: () => switchWidget(3),
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  size: 32
                ),
                color: widgetIndex == 4 ? Colors.lightGreenAccent : Colors.white,
                onPressed: () => switchWidget(4),
              ),
            ],
          ),
        ),
      )
    );
  }
}
