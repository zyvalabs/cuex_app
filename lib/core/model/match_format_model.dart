/// Represents a match format/variant option — meaning differs per sport.
/// Snooker: red ball count (15/10/6 red).
/// Pool: game variant (8-Ball / 9-Ball).
/// Heyball / Billiards: race-to target (points or frames).
class MatchFormatModel {
  final String label;
  final String value; // raw value used in match logic (e.g. '15', '8-ball', '5')

  const MatchFormatModel({
    required this.label,
    required this.value,
  });
}

// -- Snooker formats (red ball count) --
const List<MatchFormatModel> kSnookerFormats = [
  MatchFormatModel(label: '15 Red', value: '15'),
  MatchFormatModel(label: '10 Red', value: '10'),
  MatchFormatModel(label: '6 Red', value: '6'),
];

// -- Pool formats (game variant) --
const List<MatchFormatModel> kPoolFormats = [
  MatchFormatModel(label: '8-Ball', value: '8-ball'),
  MatchFormatModel(label: '9-Ball', value: '9-ball'),
];

// -- Heyball formats (race-to) --
const List<MatchFormatModel> kHeyballFormats = [
  MatchFormatModel(label: 'Best of 3', value: '3'),
  MatchFormatModel(label: 'Best of 5', value: '5'),
  MatchFormatModel(label: 'Best of 7', value: '7'),
];

// -- Billiards formats (race-to points) --
const List<MatchFormatModel> kBilliardsFormats = [
  MatchFormatModel(label: 'Race to 50', value: '50'),
  MatchFormatModel(label: 'Race to 100', value: '100'),
  MatchFormatModel(label: 'Race to 150', value: '150'),
];

/// Maps sport name -> its available match formats.
const Map<String, List<MatchFormatModel>> kMatchFormatsBySport = {
  'Snooker': kSnookerFormats,
  'Pool': kPoolFormats,
  'Heyball': kHeyballFormats,
  'Billiards': kBilliardsFormats,
};