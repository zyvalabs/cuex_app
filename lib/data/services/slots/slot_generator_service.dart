// slot_generator_service.dart
import '../../../features/shop/controllers/table/slot_mdoel.dart';

class SlotGeneratorService {
  static List<SlotModel> generateSlots({
    required String venueId,
    required String tableId,
    required String openTime,
    required String closeTime,
    required DateTime date,
  }) {
    final slots = <SlotModel>[];

    final openParts = openTime.split(':');
    final closeParts = closeTime.split(':');

    var current = DateTime(date.year, date.month, date.day, int.parse(openParts[0]), int.parse(openParts[1]));
    final end = DateTime(date.year, date.month, date.day, int.parse(closeParts[0]), int.parse(closeParts[1]));

    while (current.isBefore(end)) {
      final next = current.add(const Duration(hours: 1));
      slots.add(SlotModel(
        id: '',
        tableId: tableId,
        venueId: venueId,
        date: date,
        startTime: '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}',
        endTime: '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}',
        status: 'available',
        price: 0.0,
        discountedPrice: 0.0,
        pricingTiers: {},
        createdAt: DateTime.now(),
      ));
      current = next;
    }

    return slots;
  }
}
