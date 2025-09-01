class Usuario {
  Usuario({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: int.parse(json['id'].toString()),
    name: json['name'].toString(),
    email: json['email'].toString(),
    // Asumimos que la API devuelve un campo 'role'. Si no, por defecto es 'user'.
    role: json['role']?.toString() ?? 'user',
  );
  final int id;
  final String name;
  final String email;
  final String role;

  /// Propiedad computada para verificar fácilmente si el usuario es administrador.
  bool get isAdmin => role == 'admin';
}
