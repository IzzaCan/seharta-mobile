String translateAssetCategory(String? name) {
  if (name == null) return 'Lainnya';
  switch (name.trim()) {
    case 'Property':
    case 'Properti':
      return 'Properti';
    case 'Vehicle':
    case 'Vehicle/Transportation':
    case 'Kendaraan':
      return 'Kendaraan';
    case 'Electronics':
    case 'Elektronik':
      return 'Elektronik';
    case 'Jewelry':
    case 'Perhiasan':
      return 'Perhiasan';
    case 'Gold & Precious Metals':
    case 'Emas & Logam Mulia':
      return 'Emas & Logam Mulia';
    case 'Furniture':
    case 'Furnitur':
    case 'Mebel / Furnitur':
      return 'Mebel / Furnitur';
    case 'Valuable Documents':
    case 'Dokumen Berharga':
      return 'Dokumen Berharga';
    case 'Other':
    case 'Lainnya':
      return 'Lainnya';
    default:
      return name;
  }
}
