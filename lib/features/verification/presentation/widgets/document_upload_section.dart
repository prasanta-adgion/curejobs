import 'package:curejobs/features/media_preview/domain/enums/media_upload_purpose.dart';
import 'package:curejobs/features/media_preview/presentation/pick_and_upload_document.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/picked_file.dart';
import '../../../profile/shared/widgets/profile_section.dart';
import '../../domain/entities/verification_document_type.dart';

/// A chosen file and the document type it was added as. [type.id] is what
/// gets sent on submit.
class AddedDocument {
  const AddedDocument({
    required this.type,
    required this.file,
    required this.fileId,
  });

  final VerificationDocumentType type;
  final PickedFile file;

  /// Id of the already-uploaded file, sent as `fileId` on submit.
  final String fileId;
}

/// Icon for a document type; unknown codes get a generic file icon.
IconData documentTypeIcon(String code) => switch (code) {
  'IDENTITY_DOCUMENT' => Icons.badge_outlined,
  'PROFESSIONAL_LICENSE' => Icons.workspace_premium_outlined,
  _ => Icons.description_outlined,
};

String formatFileSize(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Red "Required" or grey "Optional" pill.
class DocumentRequiredTag extends StatelessWidget {
  const DocumentRequiredTag({super.key, required this.required});

  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: required
            ? scheme.errorContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        required ? 'Required' : 'Optional',
        style: theme.textTheme.labelSmall?.copyWith(
          color: required ? scheme.onErrorContainer : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "What to upload": every type from the API, ticked once one is added.
class DocumentChecklist extends StatelessWidget {
  const DocumentChecklist({
    super.key,
    required this.types,
    required this.added,
  });

  final List<VerificationDocumentType> types;
  final List<AddedDocument> added;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final addedIds = {for (final d in added) d.type.id};

    return Column(
      children: [
        for (var i = 0; i < types.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i < types.length - 1
                  ? Border(bottom: BorderSide(color: scheme.outlineVariant))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  addedIds.contains(types[i].id)
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: addedIds.contains(types[i].id)
                      ? AppColors.success
                      : scheme.outline,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(types[i].name, style: theme.textTheme.bodyMedium),
                ),
                DocumentRequiredTag(required: types[i].isRequired),
              ],
            ),
          ),
      ],
    );
  }
}

/// Documents added so far, each with its type and a remove button.
class AddedDocumentList extends StatelessWidget {
  const AddedDocumentList({
    super.key,
    required this.documents,
    required this.onRemove,
  });

  final List<AddedDocument> documents;
  final ValueChanged<AddedDocument> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        for (var i = 0; i < documents.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: i < documents.length - 1
                  ? Border(bottom: BorderSide(color: scheme.outlineVariant))
                  : null,
            ),
            child: Row(
              children: [
                ProfileIconTile(icon: documentTypeIcon(documents[i].type.code)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documents[i].type.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${documents[i].file.name} · '
                        '${formatFileSize(documents[i].file.sizeInBytes)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => onRemove(documents[i]),
                  icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Type dropdown → choose file → Add document. The file box stays disabled
/// until a type is picked, so every document has a type.
class AddDocumentForm extends StatefulWidget {
  const AddDocumentForm({
    super.key,
    required this.types,
    required this.onPickFile,
    required this.onAdd,
  });

  final List<VerificationDocumentType> types;

  /// Opens the source sheet and picker; null if cancelled.
  final Future<PickedFile?> Function(VerificationDocumentType type) onPickFile;
  final ValueChanged<AddedDocument> onAdd;

  @override
  State<AddDocumentForm> createState() => _AddDocumentFormState();
}

/// The form's current choice. Type, file and fileId change together, so they
/// live in one value to keep every update atomic.
class _DocumentDraft {
  const _DocumentDraft({this.type, this.file, this.fileId});

  final VerificationDocumentType? type;
  final PickedFile? file;

  /// Id of the uploaded [file], sent as `fileId` on submit.
  final String? fileId;
}

class _AddDocumentFormState extends State<AddDocumentForm> {
  final ValueNotifier<_DocumentDraft> _draft = ValueNotifier(
    const _DocumentDraft(),
  );

  /// Required types first, otherwise in API order.
  List<VerificationDocumentType> get _sortedTypes => [
    ...widget.types.where((t) => t.isRequired),
    ...widget.types.where((t) => !t.isRequired),
  ];

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  /// Picks a file and uploads it straight away; keeps the returned `fileId`
  /// for the submit call.
  Future<void> _chooseFile() async {
    final type = _draft.value.type;
    if (type == null) return;
    final uploaded = await pickAndUploadDocument(
      context,
      purpose: MediaUploadPurpose.verificationDocument,
    );
    // Ignore the result if the screen closed or the type changed meanwhile.
    if (uploaded == null || !mounted || _draft.value.type != type) return;
    _draft.value = _DocumentDraft(
      type: type,
      file: uploaded.file,
      fileId: uploaded.fileId,
    );
  }

  void _clearFile() => _draft.value = _DocumentDraft(type: _draft.value.type);

  void _add() {
    final d = _draft.value;
    final type = d.type;
    final file = d.file;
    final fileId = d.fileId;
    if (type == null || file == null || fileId == null) return;
    widget.onAdd(AddedDocument(type: type, file: file, fileId: fileId));
    _draft.value = const _DocumentDraft();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_DocumentDraft>(
      valueListenable: _draft,
      builder: (context, draft, _) => _buildForm(context, draft),
    );
  }

  Widget _buildForm(BuildContext context, _DocumentDraft draft) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final type = draft.type;
    final file = draft.file;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Document type',
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<VerificationDocumentType>(
          key: ValueKey(type?.id),
          initialValue: type,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: const Text('Select document type'),
          decoration: InputDecoration(
            prefixIcon: Icon(
              type == null
                  ? Icons.description_outlined
                  : documentTypeIcon(type.code),
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: [
            for (final t in _sortedTypes)
              DropdownMenuItem(
                value: t,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(t.name, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    DocumentRequiredTag(required: t.isRequired),
                  ],
                ),
              ),
          ],
          // Show just the name once chosen; the tag is only in the menu.
          selectedItemBuilder: (_) => [
            for (final t in _sortedTypes)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(t.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          // A new type starts over without a file.
          onChanged: (t) => _draft.value = _DocumentDraft(type: t),
        ),
        const SizedBox(height: 12),
        if (file == null)
          _ChooseFileBox(enabled: type != null, onTap: _chooseFile)
        else
          _ChosenFile(file: file, onReplace: _chooseFile, onClear: _clearFile),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: type != null && file != null ? _add : null,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add document'),
          ),
        ),
      ],
    );
  }
}

class _ChooseFileBox extends StatelessWidget {
  const _ChooseFileBox({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(10);
    final color = enabled ? scheme.primary : scheme.outline;

    return Material(
      color: enabled
          ? scheme.primaryContainer.withValues(alpha: 0.5)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, color: color),
              const SizedBox(height: 4),
              Text(
                'Choose file',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                enabled
                    ? 'Camera, gallery or files · PDF, JPG, PNG up to 5 MB'
                    : 'Select a document type first',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChosenFile extends StatelessWidget {
  const _ChosenFile({
    required this.file,
    required this.onReplace,
    required this.onClear,
  });

  final PickedFile file;
  final VoidCallback onReplace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isPdf = file.name.toLowerCase().endsWith('.pdf');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            color: scheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formatFileSize(file.sizeInBytes),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Replace',
            onPressed: onReplace,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
