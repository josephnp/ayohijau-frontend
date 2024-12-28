import 'package:flutter_app/model/user_model.dart';

class PointsHistory{
  final String id;
  final User user;
  final DateTime date;
  final int oldPoints;
  final int newPoints;
  final String status;
  final String desc;
  String? redeemPhone;
  String? redeemName;
  String? rejectReason;

  PointsHistory({
    required this.id,
    required this.user,
    required this.date,
    required this.oldPoints,
    required this.newPoints,
    required this.status,
    required this.desc,
    this.redeemPhone,
    this.redeemName,
    this.rejectReason,
  });

  factory PointsHistory.fromJson(Map<String, dynamic> json) {
    return PointsHistory(
      id: json['_id'],
      user: User.fromJson(json['userId']),
      date: DateTime.parse(json['date']),
      oldPoints: json['oldPoints'],
      newPoints: json['newPoints'],
      status: json['status'],
      desc: json['desc'],
      redeemPhone: json['redeemPhone'] ?? "",
      redeemName: json['redeemName'] ?? "",
      rejectReason: json['rejectReason'] ?? ""
    );
  }
}