///Represents a user in the app
class TwysheUser {
  final String phone;
  final String nickname;
  final String color;
  final String pin;
  final int status;

  ///Creates a new user with the specified phone, nickname, color and pin
  TwysheUser(
      {required this.phone,
      required this.nickname,
      required this.color,
      required this.pin,
      required this.status});

  factory TwysheUser.fromJson(Map<String, dynamic> json) {
    return TwysheUser(
      phone: json['phone_number'] as String,
      nickname: json['phone_name'] as String,
      color: json['phone_color'] as String,
      pin: json['phone_pin'] as String,
      status:  json['phone_status'] as int
    );
  }
}
