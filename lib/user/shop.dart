import 'package:flutter/material.dart';
import 'package:flutter_app/model/cart_model.dart';
import 'package:flutter_app/model/plant_model.dart';
import 'package:flutter_app/services/cart_services.dart';
import 'package:flutter_app/services/plant_services.dart';
import 'package:flutter_app/user/checkout.dart';
import 'package:intl/intl.dart';

class PlantStore extends StatefulWidget {
  const PlantStore({super.key});

  @override
  State<PlantStore> createState() => _PlantStoreState();
}

class _PlantStoreState extends State<PlantStore> {
  Future<List<Plant>>? plants;
  String searchQuery = '';
  Map<String, int> amount = {};
  Map<String, bool> isLoading = {};

  @override
  void initState() {
    super.initState();
    initializeCart();
    getPlants("");
  }

  void initializeCart() async {
    Cart cart = await CartService.getCart();
    setState(() {
      for (var item in cart.items) {
        amount[item.plant.id] = item.amount;
      }
    });
  }

  void getPlants(String query) {
    plants = PlantService.getPlants(query: query);
    plants?.then((plantList) {
      setState(() {
        for (var plant in plantList) {
          if (!amount.containsKey(plant.id)) {
            amount[plant.id] = 0;
          }
          if (!isLoading.containsKey(plant.id)) {
            isLoading[plant.id] = false;
          }
        }
      });
    });
  }

  void showInfoDialog(Plant plant) {
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
            child: Text(plant.name,
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
                  plant.imageUrl,
                  width: 240,
                  height: 240,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 15),
                const Text("Deskripsi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                Text(plant.desc,
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
                    Text("Penyiraman:\n${plant.water}\n",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Text("Sinar matahari:\n${plant.sunlight}\n",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Text("Suhu:\n${plant.temperature}\n",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Text("Pupuk:\n${plant.fertilizer}",
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
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 80),
          child: Column(
            children: [
              const Text('Toko Tanaman', style:
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
                  onChanged: getPlants,
                ),
              ),
              SizedBox(height: 20,),
              const Center(
                child: Text("1 tanaman = 100 poin", style: TextStyle(fontSize: 16),),
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
                      child: Text('Data item kosong'),
                    );
                  } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          mainAxisExtent: 220
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final plant = snapshot.data![index];
                          final price = NumberFormat("#,##0", "en_US").format(plant.price);

                          return Container(
                            padding: const EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showInfoDialog(plant);
                                  },
                                  child: Column(
                                    children: [
                                      Image.network(
                                        plant.imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(plant.name, style: const TextStyle(fontSize: 16)),
                                      Text("Rp. $price", style: const TextStyle(fontSize: 14)),
                                    ]
                                  )
                                ),
                                if (isLoading[plant.id] ?? false)
                                  const SizedBox(height: 18,),
                                isLoading[plant.id] ?? false
                                  ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2,))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          child: amount[plant.id] == 0
                                            ? Container(width: 48)
                                            : IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  isLoading[plant.id] = true;
                                                });
                                                await CartService.removeItemFromCart(plant.id);
                                                setState(() {
                                                  amount[plant.id] = (amount[plant.id]! - 1);
                                                  isLoading[plant.id] = false;
                                                });
                                              },
                                            )
                                        ),
                                        Text(amount[plant.id].toString(), style:
                                          const TextStyle(
                                            fontSize: 16
                                          )
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              isLoading[plant.id] = true;
                                            });
                                            await CartService.addItemToCart(plant.id);
                                            setState(() {
                                              amount[plant.id] = (amount[plant.id]! + 1);
                                              isLoading[plant.id] = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                if (isLoading[plant.id] ?? false)
                                  const SizedBox(height: 18,),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }
                )
              ]
            ),
          )
        ),
      floatingActionButton: ElevatedButton(
        onPressed: amount.values.any((element) => element > 0)
          ? () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Checkout()));
            }
          : null,
        style: ButtonStyle(
          backgroundColor: amount.values.any((element) => element > 0)
            ? MaterialStatePropertyAll(Colors.green[400])
            : const MaterialStatePropertyAll(Colors.grey),
          padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 32, vertical: 4)),
          minimumSize: const MaterialStatePropertyAll(Size(80, 50))
        ),
        child: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}