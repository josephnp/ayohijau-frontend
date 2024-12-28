// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_app/model/userplantphoto_model.dart';
import 'package:flutter_app/services/photo_services.dart';
import 'package:flutter_app/user/camera.dart';
import 'package:intl/intl.dart';

class PhotoStatus extends StatefulWidget {
  const PhotoStatus({super.key});

  @override
  State<PhotoStatus> createState() => _PhotoStatusState();
}

class _PhotoStatusState extends State<PhotoStatus> {
  void showInfoDialog(UserPlantPhoto photo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: Colors.black,
          title: Center(
            child: Column(
              children: [
                const Text("Foto Tanaman"),
                Text("(${photo.userPlant.plant.name}) ${photo.userPlant.name}",
                  style: const TextStyle(
                    fontSize: 18
                  )
                )
              ],
            )
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 450,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.6),
                  ),
                  child: Image.network(
                    photo.imageUrl,
                  )
                ),
                if (photo.verificationStatus == "Rejected")
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Text("Alasan: ${photo.rejectReason!}",
                        style: const TextStyle(
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if(photo.verificationStatus == "Rejected")
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder:(context) => Camera(photo: photo, newPhoto: false)));
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.green[400]),
                          foregroundColor: const MaterialStatePropertyAll(Colors.white)
                        ),
                        child: const Text("Foto Ulang")
                      ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red[400]),
                        foregroundColor: const MaterialStatePropertyAll(Colors.white)
                      ),
                      child: const Text("Tutup")
                    )
                  ],
                )
              ],
            ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 242),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green[200],
        title: const Text("Status Verifikasi Foto", style: 
          TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<List<UserPlantPhoto>>(
          future: PhotoService.getUserPhotos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Belum ada foto tanaman'),
              );
            } else {
              final photos = snapshot.data!;

              return ListView.separated(
                itemCount: photos.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2, height: 30,),
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        child: photo.verificationStatus == "Pending"
                          ? Icon(
                              Icons.access_time_outlined,
                              color: Colors.yellow[700],
                              size: 30,
                            )
                          : photo.verificationStatus == "Verified"
                          ? Icon(
                              Icons.done,
                              color: Colors.green[700],
                              size: 30,
                            )
                          : Icon(
                            Icons.close,
                            color: Colors.red[700],
                            size: 30
                          ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "(${DateFormat('dd MMM yyyy').format(photo.date)}) ${photo.userPlant.name}",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: IconButton(
                          onPressed: () {
                            showInfoDialog(photo);
                          },
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                            size: 28,
                          ),
                        )
                      )
                    ],
                  );
                }
              );
            }
          },
        )
      )
    );
  }
}