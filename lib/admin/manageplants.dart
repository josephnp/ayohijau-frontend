// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_app/admin/admin.dart';
import 'package:flutter_app/admin/plantform.dart';
import 'package:flutter_app/model/plant_model.dart';
import 'package:flutter_app/services/plant_services.dart';
import 'package:intl/intl.dart';

class ManagePlants extends StatefulWidget {
  const ManagePlants({super.key});

  @override
  State<ManagePlants> createState() => _ManagePlantsState();
}

class _ManagePlantsState extends State<ManagePlants> {
  String searchQuery = '';
  Future<List<Plant>>? plantData;

  @override
  void initState() {
    super.initState();
    plantData = PlantService.getPlants();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      plantData = PlantService.getPlants(query: query);
    });
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
          title: const Text('Manage Plants'),
          backgroundColor: Colors.green[300],
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:(context) => const Admin(),));
            },
          ),
        ), 
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
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
              FutureBuilder<List<Plant>>(
                future: plantData,
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
                      child: Text('No plants available'),
                    );
                  } else {
                    final plants = snapshot.data!;

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: plants.length,
                      separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2,),
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        final price = NumberFormat("#,##0", "en_US").format(plant.price);

                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.network(
                                              plant.imageUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(width: 20),
                                            Text("${plant.name}\nHarga: Rp. $price",
                                              style: const TextStyle(
                                                fontSize: 16
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed:() {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => PlantForm(data: plants[index])));
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 350,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("\nDescription:\n${plant.desc}\n"),
                                        Text("Water:\n${plant.water}\n"),
                                        Text("Sunlight:\n${plant.sunlight}\n"),
                                        Text("Temperature:\n${plant.temperature}\n"),
                                        Text("Fertilizer:\n${plant.fertilizer}\n"),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        );
                      }
                    );
                  }
                },
              )
            ]
          )
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[200],
          onPressed:() {
            Navigator.push(context, MaterialPageRoute(builder:(context) => const PlantForm(),));
          },
          child: const Icon(Icons.add),
        ),
      )
    );
  }
}