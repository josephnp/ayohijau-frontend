class Plant{
  final String id;
  final String name;
  final int price;
  final String desc;
  final String water;
  final String sunlight;
  final String temperature;
  final String fertilizer;
  final String imageUrl;

  Plant({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.water,
    required this.sunlight,
    required this.temperature,
    required this.fertilizer,
    required this.imageUrl
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      desc: json['desc'],
      water: json['water'],
      sunlight: json['sunlight'],
      temperature: json['temperature'],
      fertilizer: json['fertilizer'],
      imageUrl: json['image'],
    );
  }
}