import 'package:flutter_app/model/plant_model.dart';
import 'package:flutter_app/model/user_model.dart';

class Item{
  final Plant plant;
  final int amount;

  Item({
    required this.plant,
    required this.amount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      plant: Plant.fromJson(json['plantId']),
      amount: json['amount'],
    );
  }
}

class Cart{
  final String id;
  final User user;
  final List<Item> items;
  int? totalPrice;

  Cart({
    required this.id,
    required this.user,
    required this.items,
    this.totalPrice
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var itemFromJson = json['items'] as List;
    List<Item> itemList = itemFromJson.map((item) => Item.fromJson(item)).toList();

    return Cart(
      id: json['_id'],
      user: User.fromJson(json['userId']),
      items: itemList, 
      totalPrice: json['totalPrice'] ?? 0
    );
  }
}