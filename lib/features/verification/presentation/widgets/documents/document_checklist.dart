import 'package:flutter/material.dart';

import 'package:curejobs/app/theme/app_colors.dart';
import 'package:curejobs/core/utils/extensions/theme_extensions.dart';
import 'package:curejobs/features/verification/domain/entities/verification_document_type.dart';

import 'document_required_tag.dart';

/// "What to upload": every type from the API, ticked once one is uploaded.
class DocumentChecklist extends StatelessWidget {
  const DocumentChecklist({
    super.key,
    required this.types,
    required this.doneTypeIds,
  });

  final List<VerificationDocumentType> types;

  /// Ids of the types already uploaded.
  final Set<String> doneTypeIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < types.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i < types.length - 1
                  ? Border(
                      bottom: BorderSide(color: context.colors.outlineVariant),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  doneTypeIds.contains(types[i].id)
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: doneTypeIds.contains(types[i].id)
                      ? AppColors.success
                      : context.colors.outline,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    types[i].name,
                    style: context.textStyles.bodyMedium,
                  ),
                ),
                DocumentRequiredTag(required: types[i].isRequired),
              ],
            ),
          ),
      ],
    );
  }
}
