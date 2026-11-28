import 'package:flutter/material.dart';

import 'package:curejobs/core/services/picked_file.dart';
import 'package:curejobs/core/utils/extensions/theme_extensions.dart';
import 'package:curejobs/features/media_preview/domain/enums/media_upload_purpose.dart';
import 'package:curejobs/features/media_preview/presentation/pick_and_upload_document.dart';
import 'package:curejobs/features/verification/domain/entities/verification_document_type.dart';

import 'added_document.dart';
import 'choose_file_box.dart';
import 'chosen_file_tile.dart';
import 'document_required_tag.dart';

/// Type dropdown → choose file (uploaded straight away) → "Upload document",
/// which attaches it to the request. The file box stays disabled until a
/// type is picked, so every document has a type.
class AddDocumentForm extends StatefulWidget {
  const AddDocumentForm({
    super.key,
    required this.types,
    required this.onUpload,
  });

  final List<VerificationDocumentType> types;

  /// Attaches the document to the request; true when it worked. The form
  /// shows a spinner meanwhile and clears itself on success.
  final Future<bool> Function(AddedDocument document) onUpload;

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

  /// True while "Upload document" is attaching the file.
  bool _uploading = false;

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

  Future<void> _upload() async {
    final d = _draft.value;
    final type = d.type;
    final file = d.file;
    final fileId = d.fileId;
    if (_uploading || type == null || file == null || fileId == null) return;
    setState(() => _uploading = true);
    final ok = await widget.onUpload(
      AddedDocument(type: type, file: file, fileId: fileId),
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (ok) _draft.value = const _DocumentDraft();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_DocumentDraft>(
      valueListenable: _draft,
      builder: (context, draft, _) => _buildForm(context, draft),
    );
  }

  Widget _buildForm(BuildContext context, _DocumentDraft draft) {
    final type = draft.type;
    final file = draft.file;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Document type',
          style: context.textStyles.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        _typeDropdown(type),
        const SizedBox(height: 12),
        if (file == null)
          ChooseFileBox(enabled: type != null, onTap: _chooseFile)
        else
          ChosenFileTile(
            file: file,
            onReplace: _uploading ? null : _chooseFile,
            onClear: _uploading ? null : _clearFile,
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: type != null && file != null && !_uploading
                ? _upload
                : null,
            icon: _uploading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_rounded),
            label: Text(_uploading ? 'Uploading…' : 'Upload document'),
          ),
        ),
      ],
    );
  }

  Widget _typeDropdown(VerificationDocumentType? type) {
    return DropdownButtonFormField<VerificationDocumentType>(
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
                Expanded(child: Text(t.name, overflow: TextOverflow.ellipsis)),
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
    );
  }
}
