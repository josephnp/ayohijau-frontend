// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_app/admin/admin.dart';
import 'package:flutter_app/model/points_model.dart';
import 'package:flutter_app/services/points_services.dart';

class VerifyRedeem extends StatefulWidget {
  const VerifyRedeem({super.key});

  @override
  State<VerifyRedeem> createState() => _VerifyRedeemState();
}

class _VerifyRedeemState extends State<VerifyRedeem> {
  String searchQuery = '';
  Future<List<PointsHistory>>? pointsData;

  @override
  void initState() {
    super.initState();
    pointsData = PointService.getAllPendingPoints();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      pointsData = PointService.getAllPendingPoints(query: query);
    });
  }

  void showConfirmDialog(var id, String userId, String status, String desc, int pointRefund) {
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
                child: Text("Confirm ${status == "Verify" ? "Verify" : "Reject"} Request",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                  if (status == "Reject")
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

                            if (status == "Reject") {
                              setState(() {
                                valid = reasonController.value.text.isNotEmpty;
                              });

                              if (valid) {
                                await PointService.rejectRedeem(id, {
                                  "userId": userId,
                                  "pointRefund": pointRefund,
                                  "rejectReason": reasonController.text
                                });
                              }
                            } else {
                              await PointService.confirmRedeem(id, "Redeem poin ($desc)");
                            }
                            
                            if (valid) Navigator.push(context, MaterialPageRoute(builder:(context) => const VerifyRedeem()));
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
          title: const Text('Redeem Points'),
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
                FutureBuilder<List<PointsHistory>>(
                  future: pointsData,
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2,),
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
                              subtitle: Text("${request.redeemPhone!} - ${request.redeemName!}"),
                              trailing: SizedBox (
                                width: 96,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showConfirmDialog(request.id, request.user.id, "Verify", request.desc, (request.oldPoints - request.newPoints));
                                      },
                                      icon: Icon(Icons.check_circle_outline, color: Colors.green[500],)
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showConfirmDialog(request.id, request.user.id, "Reject", request.desc, (request.oldPoints - request.newPoints));
                                      },
                                      icon: Icon(Icons.cancel_outlined, color: Colors.red[500])
                                    ),
                                  ],
                                )
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
        ),
      )
    );
  }
}