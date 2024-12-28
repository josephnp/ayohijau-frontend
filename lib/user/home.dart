import 'package:flutter/material.dart';
import 'package:flutter_app/model/userplant_model.dart';
import 'package:flutter_app/services/points_services.dart';
import 'package:flutter_app/services/userplant_services.dart';
import 'package:flutter_app/user/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key,});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late SharedPreferences prefs;
  String trimmedName = "";
  String trimmedUsername = "";
  
  @override
  void initState() {
    super.initState();
    initializeUser();
    PointService.initializePoints();
  }

  void initializeUser() async {
    prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name')!;
    String username = prefs.getString('username')!;
    List<String> fullName = name.split(' ');

    setState(() {
      trimmedName = fullName.first;
      trimmedUsername = username.length > 8 ? "${username.substring(0, 8)}..." : username;
    });
  }

  void showInfoDialog(UserPlant userPlant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(
              color: Colors.black,
              width: 2
            )
          ),
          title: Center(
            child: Text(userPlant.plant.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
              ),
            )
          ),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  userPlant.newPlant
                    ? userPlant.plant.imageUrl
                    : userPlant.mostRecentPhotoUrl!,
                  width: 240,
                  height: 240,
                ),
                const SizedBox(height: 15),
                const Text("Deskripsi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                Text(userPlant.plant.desc,
                  style: const TextStyle(
                    fontSize: 16
                  ),
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Instruksi tanaman",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                    Text("Penyiraman: ${userPlant.plant.water}\n",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Text("Sinar matahari: ${userPlant.plant.sunlight}\n",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Text("Suhu: ${userPlant.plant.temperature}\n",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Text("Pupuk: ${userPlant.plant.fertilizer}",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
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
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome,", style:
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(trimmedName, style:
                        const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ]
                  )
                ),
                ValueListenableBuilder<int>(
                  valueListenable: PointService.pointsNotifier,
                  builder: (context, points, child) {
                    return TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder:(context) => const NavBar(initIndex: 4,),));
                      },
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 69, 121, 19)),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                        minimumSize: MaterialStatePropertyAll(Size(120, 40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 40,
                            color: Color.fromARGB(255, 213, 255, 172),
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trimmedUsername, style: 
                                const TextStyle(
                                  color: Colors.white
                                ),
                              ),
                              Text("$points poin", style: 
                                const TextStyle(
                                  color: Colors.white
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    );
                  }
                )
              ],
            ),
            const SizedBox(height: 50,),
            const Text("Tanaman-tanamanmu", style: 
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500
              )
            ),
            FutureBuilder<List<UserPlant>>(
              future: UserPlantService.getUserPlants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 200),
                          CircularProgressIndicator(),
                        ]
                      )
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 200),
                          Text('Belum ada tanaman'),
                        ]
                      ),
                    );
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];

                        return GestureDetector(
                          onTap: () {
                            showInfoDialog(item);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    item.newPlant
                                      ? item.plant.imageUrl
                                      : item.mostRecentPhotoUrl!,
                                    width: 150,
                                    height: 150,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(item.plant.name, style: const TextStyle(fontSize: 16)),
                                Text(item.name, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center,),
                              ],
                            ),
                          )
                        );
                      },
                    );
                  }
              },
            )
          ],
        ),
      ),
      )
    );
  }
}