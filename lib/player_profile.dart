import 'package:hive/hive.dart';

part 'player_profile.g.dart';

@HiveType(typeId: 0)
class PlayerProfile extends HiveObject {
  @HiveField(0)
  String nickname;
  @HiveField(1)
  String fullName;
  @HiveField(2)
  String contactNumber;
  @HiveField(3)
  String email;
  @HiveField(4)
  String address;
  @HiveField(5)
  String remarks;
  @HiveField(6)
  int levelIndex;
  @HiveField(7)
  int strengthIndex;

  PlayerProfile({
    required this.nickname,
    required this.fullName,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.remarks,
    required this.levelIndex,
    required this.strengthIndex,
  });
}
