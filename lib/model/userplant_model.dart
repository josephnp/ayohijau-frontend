import 'package:flutter_app/model/plant_model.dart';
import 'package:flutter_app/model/user_model.dart';

class UserPlant {
  final String id;
  final String name;
  final User user;
  final Plant plant;
  final bool photoToday;
  final bool newPlant;
  String? mostRecentPhotoUrl;

  UserPlant({
    required this.id,
    required this.name,
    required this.user,
    required this.plant,
    required this.photoToday,
    required this.newPlant,
    this.mostRecentPhotoUrl
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    return UserPlant(
      id: json['_id'],
      name: json['name'],
      user: User.fromJson(json['userId']),
      plant: Plant.fromJson(json['plantId']),
      photoToday: json['photoToday'] ?? false,
      newPlant: json['newPlant'] ?? false,
      mostRecentPhotoUrl: json['mostRecentPhoto'],
    );
  }
}