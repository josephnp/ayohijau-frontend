import 'package:flutter/material.dart';
import 'package:flutter_app/model/points_model.dart';
import 'package:flutter_app/services/points_services.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 242),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green[200],
        title: const Text("Riwayat Poin", style: 
          TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<PointsHistory>>(
          future: PointService.getPointsHistory(),
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
                child: Text('Belum ada riwayat poin'),
              );
            } else {
              final points = snapshot.data!;

              return ListView.separated(
                itemCount: points.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 2, height: 30,),
                itemBuilder: (context, index) {
                  final point = points[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('(HH:mm) dd MMMM yyyy').format(point.date),
                        style: const TextStyle(
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text("Poin: ${point.newPoints}",
                            style: const TextStyle(
                              fontSize: 16
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (point.newPoints > point.oldPoints) // Gain points
                            Text("(+${point.newPoints - point.oldPoints})",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green
                              ),
                            ),
                          if (point.newPoints < point.oldPoints) // Lose points
                            Text("(-${point.oldPoints - point.newPoints})",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red
                              ),
                            )
                        ],
                      ),
                      Text("Sumber: ${point.desc}",
                        style: const TextStyle(
                          fontSize: 16
                        ),
                      )
                    ],
                  );
                },
              );
            }
          },
        ),
      )
    );
  }
}