class CategoryModel {
  final String id;
  final String? familyId;
  final String name;
  final String type;
  final String? iconName;
  final bool isDefault;

  CategoryModel({
    required this.id,
    this.familyId,
    required this.name,
    required this.type,
    this.iconName,
    required this.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      familyId: json['family_id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'expense',
      iconName: json['icon_name'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'name': name,
      'type': type,
      'icon_name': iconName,
      'is_default': isDefault,
    };
  }
}
