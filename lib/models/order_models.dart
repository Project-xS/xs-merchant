class ItemContainer {
  final String name;
  final int quantity;
  final bool isVeg;
  final String? description;
  final String? picEtag;
  final String? picLink;
  final int? price;

  const ItemContainer({
    required this.name,
    required this.quantity,
    required this.isVeg,
    this.description,
    this.picEtag,
    this.picLink,
    this.price,
  });

  factory ItemContainer.fromJson(Map<String, dynamic> json) {
    return ItemContainer(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      isVeg: json['is_veg'] as bool,
      description: json['description'] as String?,
      picEtag: json['pic_etag'] as String?,
      picLink: json['pic_link'] as String?,
      price: json['price'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'is_veg': isVeg,
      'description': description,
      'pic_etag': picEtag,
      'pic_link': picLink,
      'price': price,
    };
  }
}

class OrderItemContainer {
  final int orderId;
  final String canteenName;
  final int totalPrice;
  final String deliverAt;
  final int orderedAt;
  final List<ItemContainer> items;
  // This field is not in the API response but used for local state (verification dialog)
  // If null, it means "Not Processed". If true/false, it means Accepted/Rejected.
  // We can map 'submitted' logic to this or keeping it separate.
  // For 'submitted' in local Map logic: null = deliver later, true/false = history/done?
  // Actually in existing code: submitted==null -> "Deliver Later".
  final bool? submitted;
  final List<bool?>? itemStatuses;

  const OrderItemContainer({
    required this.orderId,
    required this.canteenName,
    required this.totalPrice,
    required this.deliverAt,
    required this.orderedAt,
    required this.items,
    this.submitted,
    this.itemStatuses,
  });

  factory OrderItemContainer.fromJson(Map<String, dynamic> json) {
    return OrderItemContainer(
      orderId: (json['order_id'] as num).toInt(),
      canteenName: json['canteen_name'] as String,
      totalPrice: (json['total_price'] as num).toInt(),
      deliverAt: json['deliver_at'] as String,
      orderedAt: (json['ordered_at'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
      submitted: json['submitted'] as bool?,
      itemStatuses: json['item_statuses'] != null
          ? (json['item_statuses'] as List).map((e) => e as bool?).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'canteen_name': canteenName,
      'total_price': totalPrice,
      'deliver_at': deliverAt,
      'ordered_at': orderedAt,
      'items': items.map((e) => e.toJson()).toList(),
      'submitted': submitted,
      'item_statuses': itemStatuses,
    };
  }

  OrderItemContainer copyWith({
    int? orderId,
    String? canteenName,
    int? totalPrice,
    String? deliverAt,
    int? orderedAt,
    List<ItemContainer>? items,
    bool? submitted,
    List<bool?>? itemStatuses,
  }) {
    return OrderItemContainer(
      orderId: orderId ?? this.orderId,
      canteenName: canteenName ?? this.canteenName,
      totalPrice: totalPrice ?? this.totalPrice,
      deliverAt: deliverAt ?? this.deliverAt,
      orderedAt: orderedAt ?? this.orderedAt,
      items: items ?? this.items,
      submitted: submitted ?? this.submitted,
      itemStatuses: itemStatuses ?? this.itemStatuses,
    );
  }
}

class PastOrderItemContainer {
  final int orderId;
  final String canteenName;
  final int totalPrice;
  final bool orderStatus;
  final int orderedAt;
  final List<ItemContainer> items;

  const PastOrderItemContainer({
    required this.orderId,
    required this.canteenName,
    required this.totalPrice,
    required this.orderStatus,
    required this.orderedAt,
    required this.items,
  });

  factory PastOrderItemContainer.fromJson(Map<String, dynamic> json) {
    return PastOrderItemContainer(
      orderId: json['order_id'] as int,
      canteenName: json['canteen_name'] as String,
      totalPrice: json['total_price'] as int,
      orderStatus: json['order_status'] as bool,
      orderedAt: json['ordered_at'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'canteen_name': canteenName,
      'total_price': totalPrice,
      'order_status': orderStatus,
      'ordered_at': orderedAt,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class ActiveOrderItem {
  final int itemId;
  final String itemName;
  final int numOrdered;

  const ActiveOrderItem({
    required this.itemId,
    required this.itemName,
    required this.numOrdered,
  });

  factory ActiveOrderItem.fromJson(Map<String, dynamic> json) {
    return ActiveOrderItem(
      itemId: (json['item_id'] as num).toInt(),
      itemName: json['item_name'] as String,
      numOrdered: (json['num_ordered'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'num_ordered': numOrdered,
    };
  }
}
