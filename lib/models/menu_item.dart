class MenuItem {
  final int id;
  final String name;
  final int price;
  final bool isVeg;
  final bool available;
  final int stock;
  final String? pic;
  final String? etag;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isVeg,
    required this.available,
    required this.stock,
    this.pic,
    this.etag,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['item_id'] as int,
      name: json['name'] as String,
      price: json['price'] as int,
      isVeg: json['is_veg'] as bool,
      available: json['is_available'] as bool,
      stock: json['stock'] as int,
      pic: json['pic_link'] as String?,
      etag: json['pic_etag']?.toString().replaceAll('"', ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'name': name,
      'price': price,
      'is_veg': isVeg,
      'is_available': available,
      'stock': stock,
      'pic_link': pic,
      'pic_etag': etag,
    };
  }

  // CopyWith for easy updates
  MenuItem copyWith({
    int? id,
    String? name,
    int? price,
    bool? isVeg,
    bool? available,
    int? stock,
    String? pic,
    String? etag,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isVeg: isVeg ?? this.isVeg,
      available: available ?? this.available,
      stock: stock ?? this.stock,
      pic: pic ?? this.pic,
      etag: etag ?? this.etag,
    );
  }
}
