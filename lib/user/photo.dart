// display_plant_details_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/userplant_model.dart';
import 'package:flutter_app/model/userplantphoto_model.dart';
import 'package:flutter_app/services/photo_services.dart';
import 'package:flutter_app/user/camera.dart';
import 'package:flutter_app/user/navbar.dart';

class Photo extends StatefulWidget {
  final String imagePath;
  final bool newPhoto;
  final UserPlant? userPlant;
  final UserPlantPhoto? photo;

  const Photo({
    super.key,
    required this.imagePath,
    required this.newPhoto,
    this.userPlant,
    this.photo,
  });

  @override
  State<Photo> createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {
  bool isLoading = false;

  Future<bool> onWillPop() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Camera(userPlant: widget.userPlant, newPhoto: widget.newPhoto)));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
        child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 255, 242),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.green[200],
          title: const Text('Foto Tanaman', style: 
            TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.file(File(widget.imagePath)),
              ),
              const SizedBox(height: 16.0),
              Text(
                widget.newPhoto
                ? widget.userPlant!.name
                : widget.photo!.userPlant.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Camera(userPlant: widget.userPlant, newPhoto: widget.newPhoto)));
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red[400]),
                      foregroundColor: const MaterialStatePropertyAll(Colors.white),
                      minimumSize: const MaterialStatePropertyAll(Size(140, 40))
                    ),
                    child: const Text("Kembali",
                      style: TextStyle(
                        fontSize: 16
                      ),
                    )
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      setState(() {
                        isLoading = true;
                      });

                      if (widget.newPhoto) {
                        await PhotoService.dailyPhoto(widget.userPlant!.id, File(widget.imagePath));
                      } else {
                        await PhotoService.retakePhoto(widget.photo!.id, File(widget.imagePath));
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NavBar(initIndex: 2)));
                    },
                    style: ButtonStyle(
                      backgroundColor: isLoading
                        ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                        : MaterialStatePropertyAll(Colors.green[400]),
                      foregroundColor: const MaterialStatePropertyAll(Colors.white),
                      minimumSize: const MaterialStatePropertyAll(Size(140, 40))
                    ),
                    child: isLoading
                      ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                      : const Text("Konfirmasi",
                          style: TextStyle(
                            fontSize: 16
                          ),
                        )
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}
