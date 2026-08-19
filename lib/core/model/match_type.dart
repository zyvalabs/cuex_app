/// Represents a match type option (Solo / Singles / Doubles).
/// Not every sport supports every type — see kMatchTypesBySport below.
class MatchTypeModel {
  final String name;
  final String description;

  const MatchTypeModel({
    required this.name,
    required this.description,
  });
}

// -- Match type definitions --
const soloMatchType = MatchTypeModel(
  name: 'Solo',
  description: 'Practice by yourself',
);

const singlesMatchType = MatchTypeModel(
  name: 'Singles',
  description: 'Player 1 vs Player 2',
);

const doublesMatchType = MatchTypeModel(
  name: 'Doubles',
  description: '2 players vs 2 players',
);

/// Maps sport name -> supported match types.
/// All sports currently support Solo, Singles, and Doubles — user decides.
const Map<String, List<MatchTypeModel>> kMatchTypesBySport = {
  'Snooker': [singlesMatchType, doublesMatchType, soloMatchType],
  'Pool': [singlesMatchType, doublesMatchType, soloMatchType],
  'Heyball': [singlesMatchType, doublesMatchType, soloMatchType],
  'Billiards': [singlesMatchType, doublesMatchType, soloMatchType],
};