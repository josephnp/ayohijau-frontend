import 'package:flutter_app/model/userplant_model.dart';

class UserPlantPhoto {
  final String id;
  final String imageUrl;
  final UserPlant userPlant;
  final DateTime date;
  final String verificationStatus;
  final String? rejectReason;

  UserPlantPhoto({
    required this.id,
    required this.imageUrl,
    required this.userPlant,
    required this.date,
    required this.verificationStatus,
    this.rejectReason
  });

  factory UserPlantPhoto.fromJson(Map<String, dynamic> json) {
    return UserPlantPhoto(
      id: json['_id'],
      imageUrl: json['image'],
      userPlant: UserPlant.fromJson(json['userPlantId']),
      date: DateTime.parse(json['date']),
      verificationStatus: json['verificationStatus'],
      rejectReason: json['rejectReason']
    );
  }
}