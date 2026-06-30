import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../controllers/venue_controller.dart';

class VenueQRScreen extends StatelessWidget {
  const VenueQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final venue = VenueController.instance.venue.value;
    final venueId = venue.id;
    final cuexVenueId = 'CUEX-V-${venueId.substring(0, 8).toUpperCase()}';

    return Scaffold(
      appBar: AppBar(title: const Text('Venue QR Code')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Venue icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.primary.withOpacity(0.15),
                  border: Border.all(color: TColors.primary.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.store_rounded, size: 36, color: TColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                venue.name.isNotEmpty ? venue.name : 'Your Venue',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                cuexVenueId,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, letterSpacing: 1.5),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: QrImageView(
                  data: venueId,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              Text(
                'Show this QR to players\nso they can find and visit your venue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}