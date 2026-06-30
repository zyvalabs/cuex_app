import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../controllers/add_venue_controller.dart';

class VenueLocationStep extends StatefulWidget {
  const VenueLocationStep({super.key});

  @override
  State<VenueLocationStep> createState() => _VenueLocationStepState();
}

class _VenueLocationStepState extends State<VenueLocationStep> {
  static const _apiKey = 'AIzaSyDg3FAxoRh2n3HwRQ2O61ueAXUKmNIAGSQ';

  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();

  @override
  void dispose() {
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AddEditVenueController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // GOOGLE PLACES AUTOCOMPLETE
          GooglePlaceAutoCompleteTextField(
            focusNode: _addressFocus,
            textEditingController: c.addressController,
            googleAPIKey: _apiKey,

            debounceTime: 400,
            countries: const ['in'],
            isLatLngRequired: true,

            textInputAction: TextInputAction.done,

            inputDecoration: InputDecoration(
              labelText: 'Search Address *',
              hintText: 'Type venue address...',
              prefixIcon: const Icon(Iconsax.location, size: 18),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  TSizes.cardRadiusMd,
                ),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  TSizes.cardRadiusMd,
                ),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  TSizes.cardRadiusMd,
                ),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            // PLACE DETAILS
            getPlaceDetailWithLatLng: (Prediction prediction) {

              // SAVE LAT LNG
              c.latitude.value =
                  double.tryParse(prediction.lat ?? '0') ?? 0;

              c.longitude.value =
                  double.tryParse(prediction.lng ?? '0') ?? 0;

              // SAVE ADDRESS
              c.addressController.text =
                  prediction.description ?? '';

              // KEEP CURSOR AT END
              c.addressController.selection =
                  TextSelection.fromPosition(
                    TextPosition(
                      offset: c.addressController.text.length,
                    ),
                  );

              // EXTRACT CITY / STATE
              _extractCityState(prediction, c);

              // KEEP FOCUS ON SAME FIELD
              Future.delayed(
                const Duration(milliseconds: 100),
                    () {
                  _addressFocus.requestFocus();
                },
              );
            },

            // ITEM CLICK
            itemClick: (Prediction prediction) {

              c.addressController.text =
                  prediction.description ?? '';

              c.addressController.selection =
                  TextSelection.fromPosition(
                    TextPosition(
                      offset: c.addressController.text.length,
                    ),
                  );

              // PREVENT AUTO JUMP
              Future.delayed(
                const Duration(milliseconds: 100),
                    () {
                  _addressFocus.requestFocus();
                },
              );
            },
          ),

          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),

          // CITY
          TextFormField(
            controller: c.cityController,
            focusNode: _cityFocus,
            textInputAction: TextInputAction.next,

            decoration: const InputDecoration(
              labelText: 'City *',
              prefixIcon: Icon(
                Iconsax.building,
                size: 18,
              ),
            ),

            onFieldSubmitted: (_) {
              FocusScope.of(context)
                  .requestFocus(_stateFocus);
            },
          ),

          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),

          // STATE
          TextFormField(
            controller: c.stateController,
            focusNode: _stateFocus,
            textInputAction: TextInputAction.next,

            decoration: const InputDecoration(
              labelText: 'State',
              prefixIcon: Icon(
                Iconsax.map,
                size: 18,
              ),
            ),

            onFieldSubmitted: (_) {
              FocusScope.of(context)
                  .requestFocus(_countryFocus);
            },
          ),

          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),

          // COUNTRY
          TextFormField(
            controller: c.countryController,
            focusNode: _countryFocus,
            textInputAction: TextInputAction.done,

            decoration: const InputDecoration(
              labelText: 'Country',
              prefixIcon: Icon(
                Iconsax.global,
                size: 18,
              ),
            ),
          ),

          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),

          // LOCATION STATUS
          Obx(
                () => c.latitude.value != 0
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                TSizes.md,
              ),

              decoration: BoxDecoration(
                color: Colors.green.withOpacity(
                  0.05,
                ),

                border: Border.all(
                  color: Colors.green.withOpacity(
                    0.3,
                  ),
                ),

                borderRadius: BorderRadius.circular(
                  TSizes.cardRadiusMd,
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Iconsax.location_tick,
                    size: 16,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Location pinned: '
                          '${c.latitude.value.toStringAsFixed(6)}, '
                          '${c.longitude.value.toStringAsFixed(6)}',

                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                TSizes.md,
              ),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(
                    0.2,
                  ),
                ),

                borderRadius: BorderRadius.circular(
                  TSizes.cardRadiusMd,
                ),
              ),

              child: const Row(
                children: [

                  Icon(
                    Iconsax.location,
                    size: 16,
                    color: Colors.grey,
                  ),

                  SizedBox(width: 8),

                  Text(
                    'No location pinned yet — search address above',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // EXTRACT CITY / STATE / COUNTRY
  void _extractCityState(
      Prediction prediction,
      AddEditVenueController c,
      ) {

    final terms = prediction.terms ?? [];

    if (terms.length >= 3) {

      c.cityController.text =
          terms[terms.length - 3].value ?? '';

      c.stateController.text =
          terms[terms.length - 2].value ?? '';

      c.countryController.text =
          terms[terms.length - 1].value ?? '';

    } else if (terms.length == 2) {

      c.cityController.text =
          terms[0].value ?? '';

      c.countryController.text =
          terms[1].value ?? '';
    }
  }
}