import 'package:flutter/material.dart';

import '../../../profile/shared/widgets/profile_section.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../domain/enums/location_type.dart';
import 'create_account_fields.dart';
import 'location_autocomplete_field.dart';

/// Step 3: address. Each field suggests locations from the API.
class LocationStep extends StatelessWidget {
  const LocationStep({
    super.key,
    required this.pinCode,
    required this.area,
    required this.city,
    required this.state,
    required this.country,
  });

  final TextEditingController pinCode;
  final TextEditingController area;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController country;

  /// Fills the broader fields from a picked suggestion.
  void _fillFrom(LocationSuggestion suggestion) {
    void fill(TextEditingController controller, String? value) {
      if (value != null && value.trim().isNotEmpty) controller.text = value;
    }

    switch (suggestion.type) {
      case LocationType.area:
        fill(city, suggestion.city);
        fill(state, suggestion.state);
        fill(country, suggestion.country);
      case LocationType.city:
        fill(state, suggestion.state);
        fill(country, suggestion.country);
      case LocationType.state:
        fill(country, suggestion.country);
      case LocationType.country:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ProfileSection(
          title: 'Address',
          showDivider: false,
          child: Column(
            children: [
              LabeledTextField(
                label: 'PIN code',
                hint: '700001',
                controller: pinCode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              LocationAutocompleteField(
                label: 'Area / locality',
                hint: 'New Town',
                type: LocationType.area,
                controller: area,
                isOptional: true,
                onSelected: _fillFrom,
              ),
              const SizedBox(height: 14),
              FieldPair(
                left: LocationAutocompleteField(
                  label: 'City',
                  hint: 'Kolkata',
                  type: LocationType.city,
                  controller: city,
                  onSelected: _fillFrom,
                ),
                right: LocationAutocompleteField(
                  label: 'State',
                  hint: 'West Bengal',
                  type: LocationType.state,
                  controller: state,
                  onSelected: _fillFrom,
                ),
              ),
              const SizedBox(height: 14),
              LocationAutocompleteField(
                label: 'Country',
                hint: 'India',
                type: LocationType.country,
                controller: country,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
