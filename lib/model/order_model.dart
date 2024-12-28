import 'package:flutter_app/model/plant_model.dart';
import 'package:flutter_app/model/user_model.dart';

class Receipt{
  final Plant plant;
  final int amount;
  final List<String> name;

  Receipt({
    required this.plant,
    required this.amount,
    required this.name
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      plant: Plant.fromJson(json['plantId']),
      amount: json['amount'],
      name: List<String>.from(json['name'])
    );
  }
}

class Order{
  final String id;
  final User user;
  final DateTime orderDate;
  final List<Receipt> receipt;
  final int totalPrice;
  final String deliveryStatus;
  final String deliveryLink;
  final int orderCounter;
  String? paymentBank;
  String? paymentAccount;
  String? paymentImage;

  Order({
    required this.id,
    required this.user,
    required this.orderDate,
    required this.receipt,
    required this.totalPrice,
    required this.deliveryStatus,
    required this.deliveryLink,
    required this.orderCounter,
    this.paymentBank,
    this.paymentAccount,
    this.paymentImage
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var receiptFromJson = json['receipt'] as List;
    List<Receipt> receiptList = receiptFromJson.map((receipt) => Receipt.fromJson(receipt)).toList();

    return Order(
      id: json['_id'],
      user: User.fromJson(json['userId']),
      orderDate: DateTime.parse(json['orderDate']),
      receipt: receiptList,
      totalPrice: json['totalPrice'],
      deliveryStatus: json['deliveryStatus'],
      deliveryLink: json['deliveryLink'] ?? "",
      orderCounter: json['orderCounter'],
      paymentBank: json['paymentBank'] ?? "",
      paymentAccount: json['paymentAccount'] ?? "",
      paymentImage: json['paymentImage'] ?? "",
    );
  }
}