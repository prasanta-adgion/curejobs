import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/utils/input_validators.dart';
import '../../../../../../core/widgets/app_date_picker.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/education_params.dart';
import '../bloc/education_form_bloc.dart';
import '../widgets/delete_education_sheet.dart';
import '../widgets/education_form_fields.dart';

/// Add new education, or edit / delete [education] when given.
/// Pops `true` when something was saved or deleted.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key, this.education});

  final Education? education;

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  static const _descriptionLimit = 500;

  final _formKey = GlobalKey<FormState>();
  final _bloc = sl<EducationFormBloc>();

  late final EducationParams _initial = _paramsOf(widget.education);

  late final _degree = TextEditingController(text: _initial.degree);
  late final _field = TextEditingController(text: _initial.fieldOfStudy);
  late final _institution = TextEditingController(text: _initial.institution);
  late final _description = TextEditingController(text: _initial.description);
  late final _startYear = ValueNotifier<int?>(_initial.startYear);
  late final _endYear = ValueNotifier<int?>(_initial.completionYear);
  late final _studying = ValueNotifier<bool>(_initial.currentlyStudying);

  final _startError = ValueNotifier<String?>(null);
  final _endError = ValueNotifier<String?>(null);
  final _hasChanges = ValueNotifier(false);

  late final List<Listenable> _inputs = [
    _degree,
    _field,
    _institution,
    _description,
    _startYear,
    _endYear,
    _studying,
  ];

  bool get _isEditing => widget.education != null;

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
    _startError.dispose();
    _endError.dispose();
    _hasChanges.dispose();
    _bloc.close();
    super.dispose();
  }

  static EducationParams _paramsOf(Education? e) {
    if (e == null) return const EducationParams();
    return EducationParams(
      degree: e.degree,
      institution: e.institution,
      fieldOfStudy: e.fieldOfStudy ?? '',
      startYear: e.startYear,
      completionYear: e.currentlyStudying ? null : e.completionYear,
      currentlyStudying: e.currentlyStudying,
      description: e.description ?? '',
    );
  }

  EducationParams get _current => EducationParams(
    degree: _degree.text.trim(),
    institution: _institution.text.trim(),
    fieldOfStudy: _field.text.trim(),
    startYear: _startYear.value,
    completionYear: _studying.value ? null : _endYear.value,
    currentlyStudying: _studying.value,
    description: _description.text.trim(),
  );

  void _updateHasChanges() => _hasChanges.value = _current != _initial;

  void _pickDegree(String degree) {
    _degree.text = degree;
    _degree.selection = TextSelection.collapsed(offset: degree.length);
  }

  Future<void> _pickStart() async {
    FocusScope.of(context).unfocus();
    final picked = await AppDatePicker.pickYear(
      context,
      title: 'Start year',
      initial: _startYear.value,
      first: 1970,
      last: DateTime.now().year,
    );
    if (picked == null) return;
    _startYear.value = picked;
    _startError.value = null;
    final end = _endYear.value;
    if (end != null && end < picked) _endYear.value = null;
  }

  Future<void> _pickEnd() async {
    FocusScope.of(context).unfocus();
    final picked = await AppDatePicker.pickYear(
      context,
      title: 'End year',
      initial: _endYear.value ?? _startYear.value,
      first: _startYear.value ?? 1970,
      // Students can enter an expected completion year.
      last: DateTime.now().year + 6,
    );
    if (picked == null) return;
    _endYear.value = picked;
    _endError.value = null;
  }

  bool _validateYears() {
    _startError.value = _startYear.value == null ? 'Select a start year' : null;
    _endError.value = !_studying.value && _endYear.value == null
        ? 'Select an end year'
        : null;
    return _startError.value == null && _endError.value == null;
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final fieldsOk = _formKey.currentState?.validate() ?? false;
    final yearsOk = _validateYears();
    if (!fieldsOk || !yearsOk) return;

    _bloc.add(EducationFormSaved(_current, id: widget.education?.id));
  }

  Future<void> _delete() async {
    final education = widget.education;
    if (education == null) return;
    FocusScope.of(context).unfocus();
    final confirmed = await showDeleteEducationSheet(context, education);
    if (confirmed && mounted) _bloc.add(EducationFormDeleted(education.id));
  }

  void _onState(BuildContext context, EducationFormState state) {
    switch (state.status) {
      case EducationFormStatus.saved:
        _hasChanges.value = false;
        AppSnackbar.success(
          title: _isEditing ? 'Education updated' : 'Education added',
        );
        Navigator.of(context).pop(true);
      case EducationFormStatus.deleted:
        _hasChanges.value = false;
        AppSnackbar.success(title: 'Education deleted');
        Navigator.of(context).pop(true);
      case EducationFormStatus.failure:
        final isDelete = state.action == EducationFormAction.delete;
        AppSnackbar.error(
          title: isDelete
              ? "Couldn't delete this education"
              : "Couldn't save your education",
          message:
              state.failure?.message ?? 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: isDelete ? _delete : _save,
        );
      case EducationFormStatus.idle:
      case EducationFormStatus.saving:
      case EducationFormStatus.deleting:
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

    return BlocConsumer<EducationFormBloc, EducationFormState>(
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
                Text(_isEditing ? 'Edit education' : 'Add education'),
                Text(
                  'Hospitals check this against their requirements',
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
                        child: EducationUnsavedTag(),
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
                  _degreeSection(),
                  _institutionSection(),
                  _yearsSection(),
                  _detailsSection(),
                  if (_isEditing)
                    ProfileSection(
                      title: 'Manage',
                      child: DeleteEducationButton(
                        onPressed: state.isBusy ? null : _delete,
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: EducationSaveBar(
            label: _isEditing ? 'Save changes' : 'Add education',
            isSaving: state.isBusy,
            onSave: _save,
          ),
        ),
      ),
    );
  }

  Widget _degreeSection() {
    return ProfileSection(
      title: 'Degree',
      showDivider: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EducationLabeledField(
            label: 'Degree',
            required: true,
            child: TextFormField(
              controller: _degree,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'B.Sc. Nursing'),
              validator: (v) =>
                  InputValidators.required(v, fieldName: 'a degree'),
            ),
          ),
          const SizedBox(height: 10),
          DegreeSuggestions(controller: _degree, onPicked: _pickDegree),
          const SizedBox(height: 14),
          EducationLabeledField(
            label: 'Field of study',
            child: TextFormField(
              controller: _field,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'General Nursing'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _institutionSection() {
    return ProfileSection(
      title: 'Institution',
      child: EducationLabeledField(
        label: 'College or university',
        required: true,
        child: TextFormField(
          controller: _institution,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Manipal College of Nursing',
          ),
          validator: (v) =>
              InputValidators.required(v, fieldName: 'the institution'),
        ),
      ),
    );
  }

  Widget _yearsSection() {
    return ProfileSection(
      title: 'Years',
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _studying,
          _startYear,
          _endYear,
          _startError,
          _endError,
        ]),
        builder: (context, _) {
          final studying = _studying.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudyingNowTile(
                value: studying,
                onChanged: (value) {
                  _studying.value = value;
                  if (value) _endError.value = null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: EducationLabeledField(
                      label: 'Start year',
                      required: true,
                      child: EducationPickerField(
                        value: _startYear.value?.toString(),
                        placeholder: 'Year',
                        errorText: _startError.value,
                        onTap: _pickStart,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EducationLabeledField(
                      label: 'End year',
                      required: true,
                      enabled: !studying,
                      child: EducationPickerField(
                        value: studying
                            ? 'Present'
                            : _endYear.value?.toString(),
                        placeholder: 'Year',
                        errorText: studying ? null : _endError.value,
                        onTap: studying ? null : _pickEnd,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _detailsSection() {
    return ProfileSection(
      title: 'Details',
      child: EducationLabeledField(
        label: 'Description',
        hint: 'Honours, internships or key subjects.',
        child: TextFormField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          maxLength: _descriptionLimit,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Graduated with distinction. ICU internship.',
            alignLabelWithHint: true,
          ),
        ),
      ),
    );
  }
}
