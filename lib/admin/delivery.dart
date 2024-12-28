// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_app/admin/admin.dart';
import 'package:flutter_app/model/order_model.dart';
import 'package:flutter_app/services/order_services.dart';
import 'package:intl/intl.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key});

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  String searchQuery = '';
  Future<List<Order>>? orderData;

  @override
  void initState() {
    super.initState();
    orderData = OrderService.getAllPendingOrders();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      orderData = OrderService.getAllPendingOrders(query: query);
    });
  }

  void showInfoDialog(Order order) {
    var trackController = TextEditingController();
    bool trackingValid = true;

    bool showReject = false;
    bool showVerify = false;

    bool rejectStockLoading = false;
    bool rejectValidLoading = false;
    bool verifyLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Detail Pesanan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500
                ),
              ),
              content: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: order.receipt.map((item) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.plant.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text("× ${item.amount}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: item.name.map((name) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("- $name"),
                                );
                              }).toList()
                            ),
                            const SizedBox(height: 10,)
                          ]
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Harga",
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                        Text("Rp ${NumberFormat.decimalPattern('id_ID').format(order.totalPrice)}",
                          style: const TextStyle(
                            fontSize: 16
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 20, thickness: 2, color: Colors.black38,),
                    const Text("Bukti Pembayaran",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.network(
                      order.paymentImage!,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 5,),
                    Text("(${order.paymentBank!} - ${order.paymentAccount!})"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: rejectStockLoading || rejectValidLoading || verifyLoading ? null : () {
                            setState(() {
                              showVerify = false;
                              showReject = !showReject;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.red[500]),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            minimumSize: MaterialStateProperty.all(const Size(100, 40))
                          ),
                          child: const Text("Reject")
                        ),
                        ElevatedButton(
                          onPressed: rejectStockLoading || rejectValidLoading || verifyLoading ? null : () async{
                            setState(() {
                              showReject = false;
                              showVerify = !showVerify;
                              trackingValid = true;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green[500]),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            minimumSize: MaterialStateProperty.all(const Size(100, 40))
                          ),
                          child: const Text("Verify")
                        )
                      ],
                    ),
                    if (showReject) ...[
                      const Divider(height: 30, thickness: 2, color: Colors.black38,),
                      const Text("Pilih alasan penolakan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 10,),
                      ElevatedButton(
                        onPressed: rejectStockLoading || rejectValidLoading || verifyLoading ? null : () async {
                          setState(() {
                            rejectStockLoading = true;
                          });

                          await OrderService.rejectOrder(order.id, "stock");
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Delivery()));
                        },
                        style: ButtonStyle(
                          backgroundColor: rejectStockLoading
                            ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                            : MaterialStateProperty.all(Colors.blue[500]),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          minimumSize: MaterialStateProperty.all(const Size(240, 40))
                        ),
                        child: rejectStockLoading
                          ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                          : const Text("Stok kosong")
                      ),
                      ElevatedButton(
                        onPressed: rejectStockLoading || rejectValidLoading || verifyLoading ? null : () async {
                          setState(() {
                            rejectValidLoading = true;
                          });

                          await OrderService.rejectOrder(order.id, "invalid");
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Delivery()));
                        },
                        style: ButtonStyle(
                          backgroundColor: rejectValidLoading
                            ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                            : MaterialStateProperty.all(Colors.blue[500]),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          minimumSize: MaterialStateProperty.all(const Size(240, 40))
                        ),
                        child: rejectValidLoading
                          ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                          : const Text("Bukti pembayaran tidak valid")
                      )
                    ],
                    if (showVerify) ...[
                      const Divider(height: 30, thickness: 2, color: Colors.black38,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Data user",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Text("Nama Lengkap: ${order.user.name}"),
                          Text("Alamat: ${order.user.address}"),
                          Text("Nomor Telepon: ${order.user.phoneNumber}")
                        ],
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: trackController,
                        decoration: InputDecoration(
                          labelText: "Tracking link",
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: trackingValid ? Colors.black : Colors.red
                            )
                          )
                        ),
                      ),
                      const SizedBox(height: 20,),
                      if (!trackingValid)
                        const Text("Tracking link harus diisi",
                          style: TextStyle(
                            color: Colors.red
                          ),
                        ),
                      ElevatedButton(
                        onPressed: rejectStockLoading || rejectValidLoading || verifyLoading ? null : () async {
                          setState(() {
                            verifyLoading = true;

                            trackingValid = trackController.value.text.isNotEmpty;
                          });

                          if (trackingValid){
                            await OrderService.deliverOrder(order.id, trackController.text);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Delivery()));
                          } else {
                            setState(() {
                              verifyLoading = false;
                            });
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: verifyLoading
                            ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                            : MaterialStateProperty.all(Colors.green[500]),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          minimumSize: MaterialStateProperty.all(const Size(240, 40))
                        ),
                        child: verifyLoading
                          ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                          : const Text("Submit tracking link")
                      )
                    ]
                  ],
                ),
              ),
            );
          }
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
          title: const Text('Set Delivery'),
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
                FutureBuilder<List<Order>>(
                  future: orderData,
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
                        child: Text('Belum ada pemesanan'),
                      );
                    } else {
                      final orders = snapshot.data!;

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2,),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          
                          return ListTile(
                            title: Text(
                              "Order #${order.orderCounter} (${DateFormat('dd MMM yyyy').format(order.orderDate)})",
                              style: 
                                const TextStyle(
                                  fontSize: 16
                                ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                showInfoDialog(order);
                              },
                              icon: Icon(
                                Icons.info_outline,
                                color: Colors.blue[600],
                                size: 28,
                              ),
                            ),
                            subtitle: SizedBox(
                              width: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name: ${order.user.name}"),
                                  Text("Username: ${order.user.username}")
                                ],
                              )
                            ),
                          );
                        }
                      );
                    }
                  },
                )
              ]
            )
          )
        )
      )
    );
  }
}