class Category {
  final String id;
  final String name;
  final String institution;
  final String city;
  final String county;
  final String phone;
  final String email;

  Category({
    required this.id,
    required this.name,
    required this.institution,
    required this.city,
    required this.county,
    required this.phone,
    required this.email,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      institution: json['institution'] ?? '',
      city: json['city'],
      county: json['county'],
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}
