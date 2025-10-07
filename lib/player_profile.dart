// PlayerProfile is the data model for a badminton player.
// Annotated for Hive local storage. Each field is a HiveField.
import 'package:hive/hive.dart';

part 'player_profile.g.dart';


/// PlayerProfile is the data model for a badminton player.
/// Annotated for Hive local storage. Each field is a HiveField.
@HiveType(typeId: 0)
class PlayerProfile extends HiveObject {
  /// Nickname of the player
  @HiveField(0)
  String nickname;
  /// Full name of the player
  @HiveField(1)
  String fullName;
  /// Contact number
  @HiveField(2)
  String contactNumber;
  /// Email address
  @HiveField(3)
  String email;
  /// Home address
  @HiveField(4)
  String address;
  /// Additional remarks
  @HiveField(5)
  String remarks;
  /// Badminton level index
  @HiveField(6)
  int levelIndex;
  /// Strength index
  @HiveField(7)
  int strengthIndex;

  /// Constructor for PlayerProfile
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
