import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/plant_model.dart';
import 'package:flutter_app/services/plant_services.dart';

class Informations extends StatefulWidget {
  const Informations({super.key});

  @override
  State<Informations> createState() => _InformationsState();
}

class _InformationsState extends State<Informations> {
  String searchQuery = '';
  Future<List<Plant>>? plants;

  @override
  void initState() {
    super.initState();
    plants = PlantService.getPlants();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      plants = PlantService.getPlants(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 242),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
          child: Column(
            children: [
              const Text('Informasi Tanaman', style:
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
              const Divider(height: 40, color: Colors.green,),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cari',
                    fillColor: Colors.lightGreen.shade200,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: updateSearchQuery,
                ),
              ),
              FutureBuilder<List<Plant>>(
                future: plants,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
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
                          Text('Tanaman tidak ditemukan'),
                        ]
                      ),
                    );
                  } else {
                    final plants = snapshot.data!;

                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 15),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: plants.length,
                      separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2,),
                      itemBuilder: (context, index) {
                        final plant = plants[index];

                        return Theme(
                          data: ThemeData().copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(plant.name, style:
                              const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            children: <Widget> [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        plant.imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 20),
                                      SizedBox(
                                        width: 200,
                                        child: Text(plant.desc),
                                      )
                                    ]
                                  ),
                                  const SizedBox(height: 20,),
                                  SizedBox(
                                    width: 320,
                                    child: Table(
                                      border: TableBorder.all(
                                        color: Colors.black,
                                        width: 1.0,
                                        borderRadius: BorderRadius.circular(2.0),
                                      ),
                                      children: [
                                        TableRow(
                                          children: [
                                            Container(
                                              color: Colors.blue[200],
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  const Icon(CupertinoIcons.drop, size: 30.0),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Text(plant.water),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]
                                        ),
                                        TableRow(
                                          children: [
                                            Container(
                                              color: Colors.amber[200],
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.sunny, size: 30.0),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Text(plant.sunlight),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]
                                        ),
                                        TableRow(
                                          children: [
                                            Container(
                                              color: Colors.brown[200],
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.eco, size: 30.0),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Text(plant.fertilizer),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Container(
                                              color: Colors.red[200],
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.thermostat, size: 30.0),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Text(plant.temperature),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]
                                        )
                                      ],
                                    ),
                                  ),
                                ]
                              ),
                              const SizedBox(height: 20,)
                            ]
                          )
                        );
                      }
                    );
                  }
                },
              ),
            ],
          ),
        )
      )
    );
  }
}