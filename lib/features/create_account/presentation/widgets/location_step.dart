import 'package:flutter/material.dart';

import '../../../profile/shared/widgets/profile_section.dart';
import 'create_account_fields.dart';

/// Step 3: address, with PIN code first.
class LocationStep extends StatelessWidget {
  const LocationStep({
    super.key,
    required this.pinCode,
    required this.city,
    required this.state,
    required this.area,
    required this.country,
    required this.countries,
    required this.onCountryChanged,
  });

  final TextEditingController pinCode;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController area;
  final String? country;
  final List<String> countries;
  final ValueChanged<String?> onCountryChanged;

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
                helper: 'Fills in your city and state.',
                controller: pinCode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              FieldPair(
                left: LabeledTextField(
                  label: 'City',
                  hint: 'Kolkata',
                  controller: city,
                ),
                right: LabeledTextField(
                  label: 'State',
                  hint: 'West Bengal',
                  controller: state,
                ),
              ),
              const SizedBox(height: 14),
              LabeledTextField(
                label: 'Area / locality',
                hint: 'New Town',
                controller: area,
                isOptional: true,
              ),
              const SizedBox(height: 14),
              LabeledDropdown(
                label: 'Country',
                hint: 'Select',
                value: country,
                options: countries,
                onChanged: onCountryChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
