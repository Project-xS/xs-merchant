class LoginResponse {
  final int canteenId;
  final String canteenName;

  LoginResponse({required this.canteenId, required this.canteenName});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      canteenId: int.parse(json['canteen_id'].toString()),
      canteenName: json['canteen_name'],
    );
  }
}
