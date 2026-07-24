import 'package:flutter/material.dart';

/// Formats per sport. Key is matched against the sport name (lowercase).
const Map<String, List<String>> kSportFormats = {
  'snooker': ['6 Red', '10 Red', '15 Red'],
  'pool': ['8-Ball', '9-Ball', '10-Ball'],
  'heyball': ['8-Ball', '9-Ball'],
  'chinese 8-ball': ['8-Ball'],
  // billiards intentionally omitted — single format
};

/// Returns formats for a sport name, or empty list if it has none.
List<String> formatsForSport(String? sportName) {
  if (sportName == null) return const [];
  return kSportFormats[sportName.toLowerCase().trim()] ?? const [];
}

/// Reusable horizontal chip selector for match formats.
/// Renders nothing when the sport has no formats.
class FormatSelector extends StatelessWidget {
  const FormatSelector({
    super.key,
    required this.sportName,
    required this.selectedFormat,
    required this.onSelected,
    this.title = 'Match Format',
  });

  final String? sportName;
  final String? selectedFormat;
  final ValueChanged<String> onSelected;
  final String title;

  static const Color _accent = Color(0xFF0F6E56);
  static const Color _accentBg = Color(0xFFE1F5EE);
  static const Color _border = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    final formats = formatsForSport(sportName);
    if (formats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: formats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final format = formats[i];
              final selected = selectedFormat == format;
              return GestureDetector(
                onTap: () => onSelected(format),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? _accentBg : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? _accent : _border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    format,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? _accent : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}