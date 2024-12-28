// ignore_for_file: constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/model/cart_model.dart';
import 'package:flutter_app/services/cart_services.dart';
import 'package:flutter_app/services/order_services.dart';
import 'package:flutter_app/user/orderstatus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Future<Cart>? cart;
  late SharedPreferences prefs;

  String userid = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    prefs = await SharedPreferences.getInstance();
    address = prefs.getString('address')!;
    userid = prefs.getString('id')!;

    cart = CartService.getCart();
    setState(() {});
  }

  void showConfirmDialog(Cart cart){
    bool formValid = true;
    bool isLoading = false;

    Map<String, List<TextEditingController>> controllers = {};
    List<List<bool>> controllerValid = List.generate(cart.items.length, (index) => []);

    for (var item in cart.items) {
      controllers[item.plant.id] = List.generate(item.amount, (index) => TextEditingController());
      controllerValid[cart.items.indexOf(item)] = List.generate(item.amount, (index) => true);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Berikan nama\nuntuk tanamanmu", textAlign: TextAlign.center),
              content: SingleChildScrollView(
                child: Column(
                  children: List.generate(cart.items.length, (index) {
                    final item = cart.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.plant.name} (${item.amount})",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: List.generate(item.amount, (itemIndex) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: TextField(
                                  controller: controllers[item.plant.id]![itemIndex],
                                  decoration: InputDecoration(
                                    label: Text('Nama ${item.plant.name} ${itemIndex + 1}'),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                        color: controllerValid[index][itemIndex] ? Colors.black : Colors.red,
                                      ),
                                    ),
                                    errorText: controllerValid[index][itemIndex] ? null : "Nama sudah ada"
                                  ),
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              actions: [
                Center(
                  child: Column(
                    children: [
                      if (!formValid)
                        const Text("Nama tanaman harus diisi",
                          style: TextStyle(
                            color: Colors.red
                          ),
                        ),
                      ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          setState(() {
                            isLoading = true;
                            formValid = true;
                            for (var i = 0; i < cart.items.length; i++) {
                              for (var j = 0; j < cart.items[i].amount; j++) {
                                if (controllers[cart.items[i].plant.id]![j].text.isEmpty) {
                                  controllerValid[i][j] = false;
                                  formValid = false;
                                } else {
                                  controllerValid[i][j] = true;
                                }
                              }
                            }
                          });

                          if (formValid) {
                            Map<String, List<String>> data = {};
                            for (var item in cart.items) {
                              data[item.plant.id] = controllers[item.plant.id]!.map((controller) => controller.text).toList();
                            }

                            String response = await OrderService.checkoutOrder(data);

                            if (response == "success") {
                              CartService.resetItems();
                              Navigator.push(context, MaterialPageRoute(builder:(context) => const OrderStatus()));
                            } else {
                              setState(() {
                                isLoading = false;

                                for (var i = 0; i < cart.items.length; i++) {
                                  for (var j = 0; j < cart.items[i].amount; j++) {
                                    if (response.contains(controllers[cart.items[i].plant.id]![j].text)) {
                                      controllerValid[i][j] = false;
                                    }
                                  }
                                }
                              });
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: isLoading
                            ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                            : MaterialStatePropertyAll(Colors.green[300]),
                          foregroundColor: const MaterialStatePropertyAll(Colors.white),
                        ),
                        child: isLoading
                          ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                          : const Text('Konfirmasi'),
                      ),
                    ]
                  )
                )
              ],
            );
          }
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
        title: const Text("Rincian Pemesanan", style: 
          TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Tanaman di Keranjang", style: 
                  TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 20,),
                FutureBuilder<Cart>(
                  future: cart,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      final cart = snapshot.data!;
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Text("Tanaman", style: 
                                        TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                    Text("Jumlah", style: 
                                      TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    Text("Subtotal", style: 
                                      TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20,),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: cart.items.length,
                                  itemBuilder: (context, index) {
                                    final item = cart.items[index];
                                    if (item.amount > 0) {
                                      final subTotal = NumberFormat.decimalPattern('id_ID').format(item.plant.price * item.amount);

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 140,
                                            child: Text(item.plant.name, style: 
                                              const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Text("×  ${item.amount}", style: 
                                            const TextStyle(
                                              fontSize: 14
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text("Rp $subTotal", textAlign: TextAlign.end, style: 
                                              const TextStyle(
                                                fontSize: 14
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }
                                ),
                              ]
                            )
                          ),
                          const SizedBox(height: 8,),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  width: 80,
                                  child: Text("Total : ", style: 
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Text("Rp. ${NumberFormat.decimalPattern('id_ID').format(cart.totalPrice)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 50,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Alamat\nAnda", style:
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const Text(":", style:
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: Colors.black)
                                ),
                                width: 280,
                                height: 80,
                                child: Text(address, style:
                                  const TextStyle(
                                    fontSize: 14
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            onPressed: () {
                                showConfirmDialog(cart);
                              },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(const Size(240, 0)),
                              padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(22, 12, 22, 12)),
                              backgroundColor: MaterialStateProperty.all(Colors.green[300]),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                            child: const Text("Pesan Sekarang", textAlign: TextAlign.center, style:
                              TextStyle(
                                fontSize: 16
                              ),
                            )
                          )
                        ]
                      );
                    }
                  }
                ),
              ]
            ),
          )
        )
      )
    );
  }
}