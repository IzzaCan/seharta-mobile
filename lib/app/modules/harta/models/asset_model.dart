class AssetModel {
  final String id;
  final String familyId;
  final String categoryId;
  final String assetName;
  final double purchasePrice;
  final DateTime? purchaseDate;
  final String ownershipType;
  final String acquisitionType;
  final String? ownerUserId;
  final String? location;
  final String? serialNumber;
  final String? notes;
  final String? photoUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? creatorName;
  final String? creatorAvatarUrl;
  final String ownerName;
  final String? categoryName;

  AssetModel({
    required this.id,
    required this.familyId,
    required this.categoryId,
    required this.assetName,
    required this.purchasePrice,
    this.purchaseDate,
    required this.ownershipType,
    required this.acquisitionType,
    this.ownerUserId,
    this.location,
    this.serialNumber,
    this.notes,
    this.photoUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.creatorName,
    this.creatorAvatarUrl,
    required this.ownerName,
    this.categoryName,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] ?? '',
      familyId: json['family_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      assetName: json['asset_name'] ?? '',
      purchasePrice: json['purchase_price'] is String
          ? (double.tryParse(json['purchase_price']) ?? 0.0)
          : (json['purchase_price'] ?? 0).toDouble(),
      purchaseDate: json['purchase_date'] != null ? DateTime.parse(json['purchase_date']) : null,
      ownershipType: json['ownership_type'] ?? 'PERSONAL',
      acquisitionType: json['acquisition_type'] ?? 'PURCHASE',
      ownerUserId: json['owner_user_id'],
      location: json['location'],
      serialNumber: json['serial_number'],
      notes: json['notes'],
      photoUrl: json['photo_url'],
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      creatorName: json['creator_name'],
      creatorAvatarUrl: json['creator_avatar_url'],
      ownerName: json['owner_name'] ?? '',
      categoryName: json['category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'category_id': categoryId,
      'asset_name': assetName,
      'purchase_price': purchasePrice,
      'purchase_date': purchaseDate?.toIso8601String(),
      'ownership_type': ownershipType,
      'acquisition_type': acquisitionType,
      'owner_user_id': ownerUserId,
      'location': location,
      'serial_number': serialNumber,
      'notes': notes,
      'photo_url': photoUrl,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'creator_name': creatorName,
      'creator_avatar_url': creatorAvatarUrl,
      'owner_name': ownerName,
      'category_name': categoryName,
    };
  }
}

class AssetCategoryModel {
  final String id;
  final String? familyId;
  final String name;
  final String? iconName;
  final bool isDefault;

  AssetCategoryModel({
    required this.id,
    this.familyId,
    required this.name,
    this.iconName,
    required this.isDefault,
  });

  factory AssetCategoryModel.fromJson(Map<String, dynamic> json) {
    return AssetCategoryModel(
      id: json['id'] ?? '',
      familyId: json['family_id'],
      name: json['name'] ?? '',
      iconName: json['icon_name'],
      isDefault: json['is_default'] ?? false,
    );
  }
}
