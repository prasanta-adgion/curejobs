import 'dart:io';

import 'package:flutter/material.dart';

import '../../../profile/shared/widgets/profile_section.dart';
import 'create_account_fields.dart';

/// Step 1: photo and name.
class AboutYouStep extends StatelessWidget {
  const AboutYouStep({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.photoPath,
    required this.onUploadPhoto,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final String? photoPath;
  final VoidCallback onUploadPhoto;

  static String? _required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ProfileSection(
          title: 'Photo',
          showDivider: false,
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: scheme.primaryContainer,
                backgroundImage: photoPath == null
                    ? null
                    : FileImage(File(photoPath!)),
                child: photoPath != null
                    ? null
                    : Icon(
                        Icons.photo_camera_outlined,
                        color: scheme.onPrimaryContainer,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onUploadPhoto,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: const Text('Upload photo'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PNG, JPG or WEBP, up to 5 MB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ProfileSection(
          title: 'Your name',
          child: Column(
            children: [
              LabeledTextField(
                label: 'First name',
                hint: 'Riya',
                controller: firstName,
                isRequired: true,
                validator: (value) => _required(value, 'Enter your first name'),
              ),
              const SizedBox(height: 14),
              LabeledTextField(
                label: 'Last name',
                hint: 'Sen',
                controller: lastName,
                isRequired: true,
                validator: (value) => _required(value, 'Enter your last name'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
