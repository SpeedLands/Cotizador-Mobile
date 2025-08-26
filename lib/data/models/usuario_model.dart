class Usuario {
  Usuario({required this.id, required this.name, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: int.parse(json['id'].toString()),
    name: json['name'].toString(),
    email: json['email'].toString(),
  );
  final int id;
  final String name;
  final String email;
}
