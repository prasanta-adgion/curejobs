import 'package:flutter/material.dart';

import '../../../profile/shared/widgets/profile_section.dart';
import 'create_account_fields.dart';

/// Step 2: role and summary. Specialization opens once a category is picked.
class YourWorkStep extends StatelessWidget {
  const YourWorkStep({
    super.key,
    required this.title,
    required this.summary,
    required this.categoryName,
    required this.specializationName,
    required this.onPickCategory,
    required this.onPickSpecialization,
  });

  final TextEditingController title;
  final TextEditingController summary;
  final String? categoryName;
  final String? specializationName;
  final VoidCallback onPickCategory;
  final VoidCallback onPickSpecialization;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ProfileSection(
          title: 'Role',
          showDivider: false,
          child: Column(
            children: [
              LabeledTextField(
                label: 'Professional title',
                hint: 'Senior ICU Nurse',
                controller: title,
              ),
              const SizedBox(height: 14),
              FieldPair(
                left: LabeledPickerField(
                  label: 'Category',
                  hint: 'Select',
                  value: categoryName,
                  onTap: onPickCategory,
                ),
                right: LabeledPickerField(
                  label: 'Specialization',
                  hint: categoryName == null ? 'Pick category' : 'Select',
                  value: specializationName,
                  onTap: categoryName == null ? null : onPickSpecialization,
                ),
              ),
            ],
          ),
        ),
        ProfileSection(
          title: 'Summary',
          child: LabeledTextField(
            label: 'About you',
            hint: 'ICU nurse with 4 years in critical care.',
            controller: summary,
            isOptional: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }
}
