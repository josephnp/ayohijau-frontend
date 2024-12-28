// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/model/order_model.dart';
import 'package:flutter_app/services/order_services.dart';
import 'package:flutter_app/services/points_services.dart';
import 'package:flutter_app/services/userplant_services.dart';
import 'package:flutter_app/user/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderStatus extends StatefulWidget {
  const OrderStatus({super.key});

  @override
  State<OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  void showInfoDialog(Order order) {
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
                    if (order.deliveryStatus != "Canceled" && order.deliveryStatus != "Pending" && order.deliveryStatus != "Confirm")
                      const Divider(height: 20, thickness: 2, color: Colors.black38,),
                    order.deliveryStatus == "Waiting" || order.deliveryStatus.contains("Rejected")
                      ? waitingStatus(order.id, order.totalPrice)
                      : order.deliveryStatus == "Deliver"
                        ? deliveryStatus(order.id, order.user.id, order.orderCounter, order.receipt, order.deliveryLink)
                        : Container()
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget waitingStatus(String orderId, int totalPrice) {
    final ScrollController scrollController = ScrollController();
    var bankController = TextEditingController();
    var accountController = TextEditingController();
    bool bankValid = true;
    bool accountValid = true;

    final picker = ImagePicker();
    File? image;
    String fileName = "Upload bukti pembayaran";

    bool photoUpload = false;

    bool cancelOrder = false;
    bool cancelLoading = false;
    bool payLoading = false;
    bool payValid = true;

    Future<void> uploadImage() async {
      final uploadedFile = await picker.pickImage(source: ImageSource.gallery);

      if (uploadedFile != null) {
        setState(() {
          image = File(uploadedFile.path);
          fileName = uploadedFile.name;

          photoUpload = true;
          payValid = true;
        });
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              if (photoUpload ) ...[
                const Text("Bukti Pembayaran",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 5),
                Image.file(
                  image!,
                  width: 250,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20)
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Instruksi Pembayaran",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text("Transfer ke rekening 0123456789 sebesar Rp ${NumberFormat.decimalPattern('id_ID').format(totalPrice)} dan upload bukti pembayaran di bawah ini")
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: cancelLoading || payLoading ? null : () async {
                    await uploadImage();
                    setState(() {
                      cancelOrder = false;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12
                      )
                    ),
                    elevation: MaterialStateProperty.all(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.upload_file, size: 20),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(fileName,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: bankController,
                decoration: InputDecoration(
                  labelText: "Jenis bank (BCA, BNI, ...)",
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: bankValid ? Colors.black : Colors.red
                    )
                  )
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: accountController,
                decoration: InputDecoration(
                  labelText: "Nomor Rekening",
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: accountValid ? Colors.black : Colors.red
                    )
                  )
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              ),
              const Divider(height: 30, thickness: 2, color: Colors.black38,),
              if (!payValid)
                const Text("Data bukti pembayaran tidak valid",
                  style: TextStyle(
                    color: Colors.red
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: cancelLoading || payLoading ? null : () {
                      setState(() {
                        cancelOrder = !cancelOrder;
                      });

                      scrollController.animateTo(
                        scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red[500]),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: const Text("Batal pesanan")
                  ),
                  ElevatedButton(
                    onPressed: cancelLoading || payLoading ? null : () async{
                      setState(() {
                        cancelOrder = false;
                        payLoading = true;
                        bankValid = true;
                        accountValid = true;

                        if (bankController.value.text.isEmpty) bankValid = false;
                        if (accountController.value.text.isEmpty) accountValid = false;
                      });

                      if (photoUpload && bankValid && accountValid) {
                        await OrderService.payOrder(orderId, {
                          "bank": bankController.text,
                          "account": accountController.text
                        }, image);
                        Navigator.push(context, MaterialPageRoute(builder:(context) => const OrderStatus(),));
                      } else {
                        payValid = false;
                        payLoading = false;
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: payLoading
                        ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                        : MaterialStateProperty.all(Colors.green[500]),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: payLoading
                      ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                      : const Text("Bayar")
                  )
                ],
              ),
              if (cancelOrder) ...[
                const Divider(height: 30, thickness: 2, color: Colors.black38,),
                const Text("Konfirmasi Batal Pesanan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 10,),
                ElevatedButton (
                  onPressed: cancelLoading || payLoading ? null : () async {
                    setState(() {
                      cancelLoading = true;
                    });

                    await OrderService.cancelOrder(orderId);
                    Navigator.push(context, MaterialPageRoute(builder:(context) => const OrderStatus(),));
                  },
                  style: ButtonStyle(
                    backgroundColor: cancelLoading
                      ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                      : MaterialStateProperty.all(Colors.green[500]),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    minimumSize: MaterialStateProperty.all(const Size(80, 40)),
                  ),
                  child: cancelLoading
                    ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                    : const Text("Konfirmasi")
                )
              ]
            ],
          )
        );
      },
    );
  }

  Widget deliveryStatus(String orderId, String userId, int orderCounter, List<Receipt> receipts, String link) {
    bool confirmOrder = false;
    bool confirmLoading = false;

    void showPointsDialog() {
      bool pointsLoading = false;

      int plantCount = 0;
      for (int i = 0; i < receipts.length; i++) {
        plantCount += receipts[i].amount;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder:(context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  side: BorderSide(
                    color: Colors.black,
                    width: 4
                  )
                ),
                title: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/hand.png',
                        height: 250,
                        width: 250,
                      ),
                      const SizedBox(height: 10,),
                      Text("Selamat! Kamu berhasil mendapatkan ${plantCount*100} poin!", textAlign: TextAlign.center, style: 
                        const TextStyle(
                          fontSize: 18,
                        ),
                      )
                    ],
                  )
                ),
                actions: <Widget>[
                  Center(
                    child: ElevatedButton(
                      onPressed: pointsLoading ? null : () async {
                        setState(() {
                          pointsLoading = true;
                        });

                        List<Map<String, String>> userPlants = [];
                        for (int i = 0; i < receipts.length; i++) {
                          for (int j = 0; j < receipts[i].amount; j++) {
                            userPlants.add({
                              'plantId': receipts[i].plant.id,
                              'name': receipts[i].name[j]
                            });
                          }
                        }

                        await OrderService.confirmOrder(orderId);
                        for (var userPlant in userPlants) {
                          await UserPlantService.createUserPlant(userPlant);
                        }

                        await PointService.changePoint(userId, {
                          "point": plantCount*100,
                          "desc": "Pembelian tanaman (Order #$orderCounter)"
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NavBar(initIndex: 0,)));
                      },
                      style: ButtonStyle(
                        backgroundColor: pointsLoading
                          ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                          : MaterialStateProperty.all(Colors.green[300]),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      child: pointsLoading
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                        : const Text("OK"),
                    ),
                  )
                ],
              );  
            },
          );
        }
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            const Text("Lacak Pesanan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 10,),

            InkWell(
              child: Text(link,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[500],
                  decoration: TextDecoration.underline
                ),
              ),
              onTap: () => launch(link),
            ),
            const SizedBox(height: 10,),
            confirmOrder
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: confirmLoading ? null : () {
                        setState(() {
                          confirmOrder = false;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red[500]),
                        foregroundColor: MaterialStateProperty.all(Colors.white)
                      ),
                      child: const Text("Kembali")
                    ),
                    const SizedBox(width: 10,),
                    ElevatedButton(
                      onPressed:() async {
                        setState(() {
                          confirmLoading = true;
                        });

                        showPointsDialog();
                      },
                      style: ButtonStyle(
                        backgroundColor: confirmLoading
                          ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                          : MaterialStateProperty.all(Colors.green[500]),
                        foregroundColor: MaterialStateProperty.all(Colors.white)
                      ),
                      child: confirmLoading
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                        : const Text("Konfirmasi")
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed:() {
                    setState(() {
                      confirmOrder = true;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green[500]),
                    foregroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  child: const Text("Terima Pesanan")
                )
          ],
        );
      },
    );
  }

  Future<bool> onWillPop() async {
    Navigator.push(context, MaterialPageRoute(builder:(context) => const NavBar(initIndex: 4)));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 255, 242),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green[200],
          title: const Text("Status Pemesanan", style: 
            TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:(context) => const NavBar(initIndex: 4),));
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder<List<Order>>(
            future: OrderService.getOrderByUserId(),
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
                  itemCount: orders.length,
                  separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2, height: 30,),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          child: order.deliveryStatus.contains("Rejected") || order.deliveryStatus == "Canceled"
                            ? Icon(
                                Icons.close,
                                color: Colors.red[700],
                                size: 30
                              )
                            : order.deliveryStatus == "Waiting"
                              ? Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  color: Colors.orange[700],
                                  size: 30,
                                )
                              : order.deliveryStatus == "Pending"
                                ? Icon(
                                    Icons.access_time_outlined,
                                    color: Colors.yellow[700],
                                    size: 30,
                                  )
                                : order.deliveryStatus == "Deliver"
                                  ? Icon(
                                      Icons.motorcycle_rounded,
                                      color: Colors.green[700],
                                      size: 30,
                                    )
                                  : const Icon(Icons.done),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Order #${order.orderCounter} (${DateFormat('dd MMM yyyy').format(order.orderDate)})",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Status: ${
                                  order.deliveryStatus == "Canceled"
                                    ? "Dibatalkan"
                                    : order.deliveryStatus == "Rejected stock"
                                      ? "Ditolak - Stok kosong"
                                      : order.deliveryStatus == "Rejected invalid"
                                        ? "Ditolak - Bukti pembayaran tidak valid!"
                                        : order.deliveryStatus == "Waiting"
                                          ? "Menunggu pembayaran..."
                                          : order.deliveryStatus == "Pending"
                                            ? "Sedang diproses..."
                                            : order.deliveryStatus == "Deliver"
                                              ? "Sedang diantar..."
                                              : "Selesai"
                                }"
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: IconButton(
                            onPressed: () {
                              showInfoDialog(order);
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
      )
    );
  }
}