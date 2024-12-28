// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app/model/userplant_model.dart';
import 'package:flutter_app/model/userplantphoto_model.dart';
import 'package:flutter_app/user/navbar.dart';
import 'package:flutter_app/user/photo.dart';

class Camera extends StatefulWidget {
  final bool newPhoto;
  final UserPlant? userPlant;
  final UserPlantPhoto? photo;

  const Camera({
    super.key,
    this.userPlant,
    this.photo,
    required this.newPhoto
  });

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> onWillPop() async {
    Navigator.push(context, MaterialPageRoute(builder:(context) => const NavBar(initIndex: 2)));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Positioned(
              bottom: 4,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: SizedBox(
                width: 80.0,
                height: 80.0,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;
                        final image = await _controller.takePicture();

                        dispose();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Photo(
                              imagePath: image.path,
                              userPlant: widget.userPlant,
                              photo: widget.photo,
                              newPhoto: widget.newPhoto
                            ),
                          ),
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(
                      // side: BorderSide(color: Colors.black, width: 4.0),
                    ),
                    child: Container(
                      decoration: const ShapeDecoration(
                        shape: CircleBorder(
                          side: BorderSide(
                            color: Colors.black,
                            width: 4.0
                          )
                        )
                      ),
                    )
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 16,
              child: ElevatedButton(
                onPressed: () {
                  dispose();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NavBar(initIndex: 2)));
                },
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(Colors.black),
                  iconColor: const MaterialStatePropertyAll(Colors.white),
                  fixedSize: const MaterialStatePropertyAll(Size(70, 50)),
                  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    )
                  )
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Colors.white,
                  )
                )
              ),
            )
          ]
        ),
        // floatingActionButton: 
        // floatingActionButtonLocation: CustomFloatingActionButtonLocation(FloatingActionButtonLocation.centerDocked, 0, -20),
      )
    );
  }
}
