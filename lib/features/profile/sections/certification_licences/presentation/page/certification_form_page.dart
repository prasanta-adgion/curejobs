import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/utils/date_time_utils.dart';
import '../../../../../../core/utils/input_validators.dart';
import '../../../../../../core/widgets/app_date_picker.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/certification.dart';
import '../../domain/entities/certification_params.dart';
import '../bloc/certification_form_bloc.dart';
import '../bloc/certifications_bloc.dart';
import '../widgets/certification_form_fields.dart';
import '../widgets/delete_certification_sheet.dart';

/// Opens the form for a new certificate, or [existing] when given, and
/// reloads [CertificationsBloc] from [context] when something changed.
Future<void> openCertificationForm(
  BuildContext context, [
  Certification? existing,
]) async {
  final bloc = context.read<CertificationsBloc>();
  final changed = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => CertificationFormPage(certification: existing),
    ),
  );
  if (changed ?? false) bloc.add(const CertificationsRequested());
}

/// Add a new certificate, or edit / delete [certification] when given.
/// Pops `true` when something was saved or deleted.
class CertificationFormPage extends StatefulWidget {
  const CertificationFormPage({super.key, this.certification});

  final Certification? certification;

  @override
  State<CertificationFormPage> createState() => _CertificationFormPageState();
}

class _CertificationFormPageState extends State<CertificationFormPage> {
  static const _quickYears = [1, 2, 3, 5];

  final _formKey = GlobalKey<FormState>();
  final _bloc = sl<CertificationFormBloc>();

  late final CertificationParams _initial = _paramsOf(widget.certification);

  late final _name = TextEditingController(text: _initial.name);
  late final _issuer = TextEditingController(
    text: _initial.issuingOrganization,
  );
  late final _credentialId = TextEditingController(text: _initial.credentialId);
  late final _credentialUrl = TextEditingController(
    text: _initial.credentialUrl,
  );
  late final _issueDate = ValueNotifier<DateTime?>(_initial.issueDate);
  late final _expiryDate = ValueNotifier<DateTime?>(_initial.expiryDate);
  late final _noExpiry = ValueNotifier<bool>(_initial.doesNotExpire);

  final _issueError = ValueNotifier<String?>(null);
  final _expiryError = ValueNotifier<String?>(null);
  final _hasChanges = ValueNotifier(false);

  late final List<Listenable> _inputs = [
    _name,
    _issuer,
    _credentialId,
    _credentialUrl,
    _issueDate,
    _expiryDate,
    _noExpiry,
  ];

  bool get _isEditing => widget.certification != null;

  @override
  void initState() {
    super.initState();
    for (final input in _inputs) {
      input.addListener(_updateHasChanges);
    }
  }

  @override
  void dispose() {
    for (final input in _inputs) {
      (input as ChangeNotifier).dispose();
    }
    _issueError.dispose();
    _expiryError.dispose();
    _hasChanges.dispose();
    _bloc.close();
    super.dispose();
  }

  static CertificationParams _paramsOf(Certification? c) {
    if (c == null) return const CertificationParams();
    return CertificationParams(
      name: c.name,
      issuingOrganization: c.issuingOrganization,
      issueDate: c.issueDate,
      expiryDate: c.expiryDate,
      doesNotExpire: c.expiryDate == null,
      credentialId: c.credentialId ?? '',
      credentialUrl: c.credentialUrl ?? '',
    );
  }

  CertificationParams get _current => CertificationParams(
    name: _name.text.trim(),
    issuingOrganization: _issuer.text.trim(),
    issueDate: _issueDate.value,
    expiryDate: _noExpiry.value ? null : _expiryDate.value,
    doesNotExpire: _noExpiry.value,
    credentialId: _credentialId.text.trim(),
    credentialUrl: _credentialUrl.text.trim(),
  );

  /// What the preview card shows.
  Certification get _preview => Certification(
    id: widget.certification?.id ?? '',
    name: _name.text,
    issuingOrganization: _issuer.text,
    issueDate: _issueDate.value,
    expiryDate: _noExpiry.value ? null : _expiryDate.value,
  );

  void _updateHasChanges() => _hasChanges.value = _current != _initial;

  String? _format(DateTime? d) => d == null ? null : DateTimeUtils.day(d);

  void _pickName(String name) {
    _name.text = name;
    _name.selection = TextSelection.collapsed(offset: name.length);
  }

  Future<void> _pickIssue() async {
    final picked = await AppDatePicker.pickDate(
      context,
      title: 'Issue date',
      initial: _issueDate.value,
      first: DateTime(1970),
      last: DateTime.now(),
      shortcuts: [AppDateShortcut('Today', DateTime.now())],
    );
    if (picked == null) return;
    _issueDate.value = picked;
    _issueError.value = null;
    final expiry = _expiryDate.value;
    if (expiry != null && !expiry.isAfter(picked)) _expiryDate.value = null;
  }

  Future<void> _pickExpiry() async {
    final issue = _issueDate.value;
    final picked = await AppDatePicker.pickDate(
      context,
      title: 'Expiry date',
      initial: _expiryDate.value,
      first: issue?.add(const Duration(days: 1)) ?? DateTime(1970),
      last: DateTime(DateTime.now().year + 20, 12, 31),
      shortcuts: issue == null
          ? const []
          : [
              for (final years in _quickYears)
                AppDateShortcut(
                  years == 1 ? '+1 yr' : '+$years yrs',
                  DateTimeUtils.addYears(issue, years),
                ),
            ],
    );
    if (picked == null) return;
    _expiryDate.value = picked;
    _expiryError.value = null;
  }

  /// Expiry = issue date + [years].
  void _setExpiryIn(int years) {
    final issue = _issueDate.value;
    if (issue == null) return;
    _expiryDate.value = DateTimeUtils.addYears(issue, years);
    _expiryError.value = null;
  }

  String? _validateUrl(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? null : 'Enter a link starting with https://';
  }

  bool _validateDates() {
    _issueError.value = _issueDate.value == null
        ? 'Select an issue date'
        : null;
    _expiryError.value = !_noExpiry.value && _expiryDate.value == null
        ? 'Select an expiry date'
        : null;
    return _issueError.value == null && _expiryError.value == null;
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final fieldsOk = _formKey.currentState?.validate() ?? false;
    final datesOk = _validateDates();
    if (!fieldsOk || !datesOk) return;

    _bloc.add(CertificationFormSaved(_current, id: widget.certification?.id));
  }

  Future<void> _delete() async {
    final certification = widget.certification;
    if (certification == null) return;
    FocusScope.of(context).unfocus();
    final confirmed = await showDeleteCertificationSheet(
      context,
      certification,
    );
    if (confirmed && mounted) {
      _bloc.add(CertificationFormDeleted(certification.id));
    }
  }

  void _onState(BuildContext context, CertificationFormState state) {
    switch (state.status) {
      case CertificationFormStatus.saved:
        _hasChanges.value = false;
        AppSnackbar.success(
          title: _isEditing ? 'Certificate updated' : 'Certificate added',
        );
        Navigator.of(context).pop(true);
      case CertificationFormStatus.deleted:
        _hasChanges.value = false;
        AppSnackbar.success(title: 'Certificate deleted');
        Navigator.of(context).pop(true);
      case CertificationFormStatus.failure:
        final isDelete = state.action == CertificationFormAction.delete;
        AppSnackbar.error(
          title: isDelete
              ? "Couldn't delete this certificate"
              : "Couldn't save your certificate",
          message:
              state.failure?.message ?? 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: isDelete ? _delete : _save,
        );
      case CertificationFormStatus.idle:
      case CertificationFormStatus.saving:
      case CertificationFormStatus.deleting:
        break;
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text("Your edits haven't been saved."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if ((discard ?? false) && mounted) {
      _hasChanges.value = false;
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BlocConsumer<CertificationFormBloc, CertificationFormState>(
      bloc: _bloc,
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _onState,
      builder: (context, state) => ValueListenableBuilder<bool>(
        valueListenable: _hasChanges,
        builder: (context, hasChanges, child) => PopScope(
          canPop: !hasChanges && !state.isBusy,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !state.isBusy) _confirmDiscard();
          },
          child: child!,
        ),
        child: Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Close',
              icon: const Icon(AppIcons.close),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEditing ? 'Edit certificate' : 'Add certificate'),
                Text(
                  'Hospitals verify these before hiring',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: _hasChanges,
                builder: (context, hasChanges, _) => hasChanges
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: CertificationUnsavedTag(),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: scheme.outlineVariant),
            ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: ListenableBuilder(
                      listenable: Listenable.merge(_inputs),
                      builder: (context, _) =>
                          CertificationPreviewCard(certification: _preview),
                    ),
                  ),
                  _certificateSection(),
                  _validitySection(),
                  _proofSection(),
                  if (_isEditing)
                    ProfileSection(
                      title: 'Manage',
                      child: DeleteCertificationButton(
                        onPressed: state.isBusy ? null : _delete,
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CertificationSaveBar(
            label: _isEditing ? 'Save changes' : 'Add certificate',
            isSaving: state.isBusy,
            onSave: _save,
          ),
        ),
      ),
    );
  }

  Widget _certificateSection() {
    return ProfileSection(
      title: 'Certificate',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CertificationLabeledField(
            label: 'Name',
            required: true,
            child: TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'BLS Provider'),
              validator: (v) =>
                  InputValidators.required(v, fieldName: 'a name'),
            ),
          ),
          const SizedBox(height: 10),
          CertificationNameSuggestions(controller: _name, onPicked: _pickName),
          const SizedBox(height: 14),
          CertificationLabeledField(
            label: 'Issued by',
            required: true,
            child: TextFormField(
              controller: _issuer,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'American Heart Association',
              ),
              validator: (v) =>
                  InputValidators.required(v, fieldName: 'the issuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _validitySection() {
    final theme = Theme.of(context);

    return ProfileSection(
      title: 'Validity',
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _issueDate,
          _expiryDate,
          _noExpiry,
          _issueError,
          _expiryError,
        ]),
        builder: (context, _) {
          final noExpiry = _noExpiry.value;
          final issue = _issueDate.value;
          final expiry = _expiryDate.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CertificationLabeledField(
                      label: 'Issue date',
                      required: true,
                      child: CertificationDateField(
                        value: _format(issue),
                        errorText: _issueError.value,
                        onTap: _pickIssue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CertificationLabeledField(
                      label: 'Expiry date',
                      required: true,
                      enabled: !noExpiry,
                      child: CertificationDateField(
                        value: noExpiry ? 'Never' : _format(expiry),
                        errorText: noExpiry ? null : _expiryError.value,
                        onTap: noExpiry ? null : _pickExpiry,
                      ),
                    ),
                  ),
                ],
              ),
              if (!noExpiry) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      issue == null ? 'Pick an issue date, then:' : 'Quick:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    for (final years in _quickYears)
                      CertificationChip(
                        label: years == 1 ? '+1 yr' : '+$years yrs',
                        selected:
                            issue != null &&
                            expiry == DateTimeUtils.addYears(issue, years),
                        onTap: issue == null ? null : () => _setExpiryIn(years),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              NoExpiryTile(
                value: noExpiry,
                onChanged: (value) {
                  _noExpiry.value = value;
                  if (value) _expiryError.value = null;
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _proofSection() {
    return ProfileSection(
      title: 'Proof',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CertificationLabeledField(
            label: 'Credential ID',
            hint: 'Optional. Helps hospitals verify you faster.',
            child: TextFormField(
              controller: _credentialId,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'AHA-123456'),
            ),
          ),
          const SizedBox(height: 14),
          CertificationLabeledField(
            label: 'Verification link',
            child: TextFormField(
              controller: _credentialUrl,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              validator: _validateUrl,
              decoration: const InputDecoration(
                hintText: 'https://',
                prefixIcon: Icon(Icons.link_rounded, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
