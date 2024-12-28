// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/model/points_model.dart';
import 'package:flutter_app/services/points_services.dart';
import 'package:flutter_app/user/navbar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> eWalletList = <String>['GoPay', 'OVO', 'DANA'];
const List<Map<int,int>> moneyList = [{10000: 200}, {20000: 400}, {50000: 1000}];

class RedeemPoints extends StatefulWidget {
  const RedeemPoints({super.key});

  @override
  State<RedeemPoints> createState() => _RedeemPointsState();
}

class _RedeemPointsState extends State<RedeemPoints> with SingleTickerProviderStateMixin {
  late SharedPreferences prefs;
  late TabController tabController;
  String userid = "";

  var phoneController = TextEditingController();
  var nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeUser();
    tabController = TabController(length: 2, vsync: this);
  }

  void initializeUser() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs.getString('id')!;
    phoneController.text = prefs.getString('phoneNumber')!;
    nameController.text = prefs.getString('name')!;

    setState(() {});
  }

  void showPhoneDialog(String wallet, int money, int points){
    bool phoneValid = true;
    bool nameValid = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:(context, setState) {
            return AlertDialog(
              title: Text(
                "Redeem $wallet ($points poin)",
                style: const TextStyle(
                  fontSize: 20
                ),
                textAlign: TextAlign.center
              ),
              content: SingleChildScrollView(
                child: Column(
                  children:[
                    const SizedBox(height: 10,),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: "Nomor Telepon",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: phoneValid ? Colors.black : Colors.red
                          )
                        )
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Nama Pengguna $wallet",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: nameValid ? Colors.black : Colors.red
                          )
                        )
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20,),
                    if(!phoneValid || !nameValid) 
                      const Text("Data redeem tidak valid",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                            minimumSize: const MaterialStatePropertyAll(Size(40, 40)),
                            backgroundColor: MaterialStatePropertyAll(Colors.blue[400]),
                            foregroundColor: const MaterialStatePropertyAll(Colors.white)
                          ),
                          child: const Center(
                            child: Text("Cancel")
                          )
                        ),
                        ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            setState(() {
                              isLoading = true;
                              phoneValid = phoneController.value.text.isNotEmpty;
                              nameValid = nameController.value.text.isNotEmpty;
                            });

                            if (phoneValid && nameValid){
                              await PointService.requestRedeem(userid, {
                                "point": points*-1,
                                "desc": "$wallet - Rp ${NumberFormat("#,##0", "id_ID").format(money)}",
                                "redeemPhone": phoneController.text,
                                "redeemName": nameController.text
                              });
                              Navigator.push(context, MaterialPageRoute(builder:(context) => const RedeemPoints()));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Poin berhasil ditukarkan.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            minimumSize: const MaterialStatePropertyAll(Size(40, 40)),
                            backgroundColor: isLoading
                              ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                              : MaterialStatePropertyAll(Colors.green[400]),
                            foregroundColor: const MaterialStatePropertyAll(Colors.white)
                          ),
                          child: isLoading
                            ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                            : const Center(
                              child: Text("Confirm")
                            )
                        ),
                      ]
                    )
                  ]
                )
              )
            );
          }
        );
      }
    );
  }

  Future<bool> onWillPop() async {
    Navigator.push(context, MaterialPageRoute(builder:(context) => const NavBar(initIndex: 4),));
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
          title: const Text("Redeem Poin", style: 
            TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        body: Column(
          children:[
            const SizedBox(height: 20,),
            Container(
              width: 300,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: PointService.pointsNotifier,
                builder: (context, points, child) {
                  return ListTile(
                    title: Text('Poin Hijau: $points', style:
                      const TextStyle(
                        color: Colors.white
                      )
                    ),
                  );
                }
              )
            ),
            const SizedBox(height: 20,),
            TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: "Redeem Poin"),
                Tab(text: "Status Pending")
              ]
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: <Widget>[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: eWalletList.length,
                    separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2, height: 10,),
                    itemBuilder: (context, index) {
                      final wallet = eWalletList[index];
                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Image.asset(
                                  'assets/img/$wallet.png',
                                  height: 20,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Text(wallet, style:
                                const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                            ]
                          ),
                          children: [
                            Column(
                              children: moneyList.map((map) {
                                int money = map.keys.first;
                                int points = map.values.first;

                                return ListTile(
                                  title: Text('Rp ${NumberFormat("#,##0", "id_ID").format(money)} ($points poin)'),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      if (PointService.pointsNotifier.value >= points) {
                                        showPhoneDialog(wallet, money, points);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Poin tidak cukup untuk ditukarkan.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.green[400]),
                                      foregroundColor: MaterialStateProperty.all(Colors.white)
                                    ),
                                    child: const Text("Redeem")
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        )
                      );
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: FutureBuilder<List<PointsHistory>>(
                      future: PointService.getPendingPoints(),
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
                            child: Text('Belum ada permintaan redeem'),
                          );
                        } else {
                          final requests = snapshot.data!;

                          return ListView.separated(
                            itemCount: requests.length,
                            separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2, height: 30,),
                            itemBuilder: (context, index) {
                              final request = requests[index];
                              
                              return ListTile(
                                leading: request.status == "Pending"
                                  ? Icon(
                                      Icons.access_time_outlined,
                                      color: Colors.yellow[700],
                                      size: 30,
                                    )
                                  : Icon(
                                    Icons.close,
                                    color: Colors.red[700],
                                    size: 30
                                  ),
                                  title: Text(request.desc),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${request.redeemPhone!} - ${request.redeemName!}"),
                                      if (request.status == "Rejected")
                                        Text("Alasan: ${request.rejectReason!}")
                                    ]
                                  )
                              );
                            }
                          );
                        }
                      },
                    )
                  )
                ]
              ),
            )
          ]
        )
      )
    );
  }
}