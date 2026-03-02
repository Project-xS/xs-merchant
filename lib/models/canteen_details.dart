class CanteenDetails {
  CanteenDetails({
    required this.canteenId,
    required this.canteenName,
    required this.location,
    required this.isOpen,
    this.openingTime,
    this.closingTime,
    this.picEtag,
  });

  final int canteenId;
  final String canteenName;
  final String location;
  final String? openingTime;
  final String? closingTime;
  final bool isOpen;
  final String? picEtag;

  bool get isAlwaysOpen => openingTime == null && closingTime == null;

  factory CanteenDetails.fromJson(Map<String, dynamic> json) {
    final canteenIdRaw = json['canteen_id'];
    final canteenNameRaw = json['canteen_name'];
    final locationRaw = json['location'];

    return CanteenDetails(
      canteenId: canteenIdRaw is num
          ? canteenIdRaw.toInt()
          : int.tryParse('$canteenIdRaw') ?? 0,
      canteenName: canteenNameRaw?.toString() ?? '',
      location: locationRaw?.toString() ?? '',
      openingTime:
          json['opening_time']?.toString(),
      closingTime:
          json['closing_time']?.toString(),
      isOpen: json['is_open'] == true,
      picEtag: json['pic_etag']?.toString(),
    );
  }

  CanteenDetails copyWith({
    int? canteenId,
    String? canteenName,
    String? location,
    String? openingTime,
    String? closingTime,
    bool? isOpen,
    String? picEtag,
  }) {
    return CanteenDetails(
      canteenId: canteenId ?? this.canteenId,
      canteenName: canteenName ?? this.canteenName,
      location: location ?? this.location,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isOpen: isOpen ?? this.isOpen,
      picEtag: picEtag ?? this.picEtag,
    );
  }
}
