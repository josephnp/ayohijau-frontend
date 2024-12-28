// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_app/admin/admin.dart';
import 'package:flutter_app/model/userplant_model.dart';
import 'package:flutter_app/model/userplantphoto_model.dart';
import 'package:flutter_app/services/photo_services.dart';
import 'package:flutter_app/services/points_services.dart';
import 'package:intl/intl.dart';

class VerifyPhotos extends StatefulWidget {
  const VerifyPhotos({super.key});

  @override
  State<VerifyPhotos> createState() => _VerifyPhotosState();
}

class _VerifyPhotosState extends State<VerifyPhotos> {
  String searchQuery = '';
  Future<List<UserPlantPhoto>>? photoData;

  @override
  void initState() {
    super.initState();
    photoData = PhotoService.getPendingPlantPhotos();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      photoData = PhotoService.getPendingPlantPhotos(query: query);
    });
  }

  void showConfirmDialog(var id, UserPlant userPlant, DateTime date, String status) {
    var reasonController = TextEditingController();
    bool valid = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:(context, setState) {
            return AlertDialog(
              title: Center(
                child: Text("Confirm ${status == "Verified" ? "Verify" : "Reject"} Photo",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                  if (status == "Rejected")
                    Column(
                      children: [
                        TextField(
                          controller: reasonController,
                          decoration: InputDecoration(
                            labelText: 'Reject Reason',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(
                                color: valid ? Colors.black : Colors.red
                              )
                            )
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,
                        ),
                        if (!valid) 
                          const Text("Reject reason is empty",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue[200]),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: const Text("Cancel"),
                          onPressed: () async{ 
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20,),
                        ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            setState (() {
                              isLoading = true;
                            });

                            if (status == "Rejected") {
                              setState(() {
                                valid = reasonController.value.text.isNotEmpty;
                              });

                              if (valid) {
                                await PhotoService.rejectPhoto(id, reasonController.value.text);
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            } else {
                              await PhotoService.verifyPhoto(id);
                              await PointService.changePoint(userPlant.user.id, {
                                "point": 10,
                                "desc": "Foto tanaman (${userPlant.name} - ${DateFormat('dd MMM yyyy').format(date)})"
                              });
                            }
                            
                            if (valid) Navigator.push(context, MaterialPageRoute(builder:(context) => const VerifyPhotos()));
                          },
                          style: ButtonStyle(
                            backgroundColor: isLoading
                              ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                              : MaterialStateProperty.all(Colors.green[200]),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: isLoading
                            ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                            : const Text("Confirm"),
                        ),
                      ]
                    )
                  ]
                )
              ),
            );
          },
        );
      }
    );
  }

  Future<bool> onWillPop() async {
    Navigator.push(context, MaterialPageRoute(builder:(context) => const Admin()));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Verify Photos'),
          backgroundColor: Colors.green[300],
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:(context) => const Admin()));
            },
          ) ,
        ), 
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(125.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: updateSearchQuery,
                  ),
                ),
                const SizedBox(height: 10,),
                FutureBuilder<List<UserPlantPhoto>>(
                  future: photoData,
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: photos.length,
                        separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2,),
                        itemBuilder: (context, index) {
                          final photo = photos[index];
                          
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(photo.imageUrl, height: 400,),
                              SizedBox(
                                height: 400,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("(${DateFormat('HH:mm, dd MMM yyyy').format(photo.date)})\n"),
                                          Text("User:\n${photo.userPlant.user.username}\n"),
                                          Text("Nama Tanaman:\n${photo.userPlant.name}\n"),
                                          Text("Jenis Tanaman:\n${photo.userPlant.plant.name}\n"),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              showConfirmDialog(photo.id, photo.userPlant, photo.date, "Verified");
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStatePropertyAll(Colors.green.shade400),
                                              foregroundColor: const MaterialStatePropertyAll(Colors.white),
                                              minimumSize: const MaterialStatePropertyAll(Size(100, 40)),
                                            ),
                                            child: const Text("Verify")
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              showConfirmDialog(photo.id, photo.userPlant, photo.date, "Rejected");
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStatePropertyAll(Colors.red.shade400),
                                              foregroundColor: const MaterialStatePropertyAll(Colors.white),
                                              minimumSize: const MaterialStatePropertyAll(Size(100, 40)),
                                            ),
                                            child: const Text("Reject")
                                          ),
                                        ],
                                      )
                                      
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      );
                    }
                  },
                )
              ],
            )
          )
        )
      )
    );
  }
}