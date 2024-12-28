class User{
  final String id;
  final String name;
  final String username;
  final String phoneNumber;
  final String address;
  final String email;
  final String password;
  final int point;
  final String role;

  User({
    required this.name,
    required this.username,
    required this.phoneNumber,
    required this.address,
    required this.email,
    required this.password,
    required this.point,
    required this.role,
    required this.id
  });

  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['_id'],
    name: json['name'],
    username: json['username'],
    phoneNumber: json['phoneNumber'] ?? "",
    address: json['address'],
    email: json['email'],
    password: json['password'],
    point: json['point'],
    role: json['role'],
  );
  }
}