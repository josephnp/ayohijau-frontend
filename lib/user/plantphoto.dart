import 'package:flutter/material.dart';
import 'package:flutter_app/model/userplant_model.dart';
import 'package:flutter_app/services/userplant_services.dart';
import 'package:flutter_app/user/camera.dart';

class PlantPhoto extends StatefulWidget {
  const PlantPhoto({super.key});

  @override
  State<PlantPhoto> createState() => _PlantPhotoState();
}

class _PlantPhotoState extends State<PlantPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 242),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Foto Tanaman',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(
              height: 40,
              color: Colors.green,
            ),
            const Center(
              child: Text("1 foto tanaman = 10 poin", style: TextStyle(fontSize: 16),),
            ),
            const SizedBox(height: 20,),
            Expanded(
              child: FutureBuilder<List<UserPlant>>(
                future: UserPlantService.getUserPlants(),
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
                      child: Text('Belum ada tanaman'),
                    );
                  } else {
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2, height: 30,),
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                child: Image.network(
                                  item.newPlant
                                    ? item.plant.imageUrl
                                    : item.mostRecentPhotoUrl!,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                    "${item.name}\n(${item.plant.name})",
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: item.photoToday
                                    ? null
                                    : () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Camera(userPlant: item, newPhoto: true,)));
                                      },
                                  style: ButtonStyle(
                                    backgroundColor: item.photoToday
                                      ? MaterialStateProperty.all(Colors.grey)
                                      : MaterialStateProperty.all(Colors.green[400]),
                                    foregroundColor: MaterialStateProperty.all(Colors.white),
                                  ),
                                  child: Text(
                                    item.photoToday
                                      ? "Sudah"
                                      : "Ambil foto",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14
                                    ),
                                  )
                                ),
                              )
                            ],
                          )
                        );
                      }
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
