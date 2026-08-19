/// Lightweight LOCAL model for sport selection UI.
/// Not connected to Firestore — sports list is hardcoded/static for now.
/// If sports ever need to be admin-managed (add/remove without app update),
/// switch to the Firestore-backed SportModel instead.
class SportsModel {
  final String name;
  final String imagePath;

  const SportsModel({
    required this.name,
    required this.imagePath,
  });
}

/// Static list of supported sports — edit this list directly to add/remove sports.
const List<SportsModel> kSports = [
  SportsModel(name: 'Snooker', imagePath: 'assets/images/sports/snooker.png'),
  SportsModel(name: 'Pool', imagePath: 'assets/images/sports/pool.png'),
  SportsModel(name: 'Heyball', imagePath: 'assets/images/sports/heyball.png'),
  SportsModel(name: 'Billiards', imagePath: 'assets/images/sports/billiard.png'),
];