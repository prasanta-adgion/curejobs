import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/utils/date_time_utils.dart';
import '../../../../../../core/utils/input_validators.dart';
import '../../../../../../core/widgets/app_date_picker.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/employment_type.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/experience_params.dart';
import '../bloc/experience_form_bloc.dart';
import '../widgets/delete_experience_sheet.dart';
import '../widgets/employment_type_sheet.dart';
import '../widgets/experience_form_fields.dart';
import '../widgets/experience_save_bar.dart';

/// Add a new position, or edit / delete [experience] when given.
/// Pops `true` when something was saved or deleted.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key, this.experience});

  final Experience? experience;

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  static const _responsibilitiesLimit = 1000;

  final _formKey = GlobalKey<FormState>();
  final _bloc = sl<ExperienceFormBloc>();

  late final ExperienceParams _initial = _paramsOf(widget.experience);

  late final _jobTitle = TextEditingController(text: _initial.jobTitle);
  late final _organization = TextEditingController(
    text: _initial.organizationName,
  );
  late final _location = TextEditingController(text: _initial.location);
  late final _responsibilities = TextEditingController(
    text: _initial.responsibilities,
  );
  late final _employmentType = ValueNotifier<EmploymentType?>(
    _initial.employmentType,
  );
  late final _startDate = ValueNotifier<DateTime?>(_initial.startDate);
  late final _endDate = ValueNotifier<DateTime?>(_initial.endDate);
  late final _currentlyWorking = ValueNotifier<bool>(_initial.currentlyWorking);

  final _startError = ValueNotifier<String?>(null);
  final _endError = ValueNotifier<String?>(null);
  final _hasChanges = ValueNotifier(false);

  late final List<Listenable> _inputs = [
    _jobTitle,
    _organization,
    _location,
    _responsibilities,
    _employmentType,
    _startDate,
    _endDate,
    _currentlyWorking,
  ];

  bool get _isEditing => widget.experience != null;

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

  static ExperienceParams _paramsOf(Experience? e) {
    if (e == null) return const ExperienceParams();
    return ExperienceParams(
      jobTitle: e.jobTitle,
      organizationName: e.organizationName,
      employmentType: EmploymentType.fromApi(e.employmentType),
      startDate: e.startDate,
      endDate: e.currentlyWorking ? null : e.endDate,
      currentlyWorking: e.currentlyWorking,
      location: e.location ?? '',
      responsibilities: e.responsibilities ?? '',
    );
  }

  ExperienceParams get _current => ExperienceParams(
    jobTitle: _jobTitle.text.trim(),
    organizationName: _organization.text.trim(),
    employmentType: _employmentType.value,
    startDate: _startDate.value,
    endDate: _currentlyWorking.value ? null : _endDate.value,
    currentlyWorking: _currentlyWorking.value,
    location: _location.text.trim(),
    responsibilities: _responsibilities.text.trim(),
  );

  void _updateHasChanges() => _hasChanges.value = _current != _initial;

  String? _formatMonth(DateTime? d) =>
      d == null ? null : DateTimeUtils.monthYear(d);

  Future<DateTime?> _pickMonth(
    DateTime? initial, {
    required String title,
    DateTime? first,
  }) {
    return AppDatePicker.pickMonth(
      context,
      title: title,
      initial: initial,
      first: first ?? DateTime(1970),
      last: DateTime.now(),
    );
  }

  Future<void> _pickStart() async {
    final picked = await _pickMonth(_startDate.value, title: 'Start date');
    if (picked == null) return;
    _startDate.value = picked;
    _startError.value = null;
    final end = _endDate.value;
    if (end != null && end.isBefore(picked)) _endDate.value = null;
  }

  Future<void> _pickEnd() async {
    final picked = await _pickMonth(
      _endDate.value ?? _startDate.value,
      title: 'End date',
      first: _startDate.value,
    );
    if (picked == null) return;
    _endDate.value = picked;
    _endError.value = null;
  }

  void _pickJobTitle(String title) {
    _jobTitle.text = title;
    _jobTitle.selection = TextSelection.collapsed(offset: title.length);
  }

  Future<void> _pickEmploymentType() async {
    FocusScope.of(context).unfocus();
    final picked = await showEmploymentTypeSheet(
      context,
      selected: _employmentType.value,
    );
    if (picked != null) _employmentType.value = picked;
  }

  bool _validateDates() {
    final start = _startDate.value;
    final end = _endDate.value;
    _startError.value = start == null ? 'Select a start date' : null;
    _endError.value = !_currentlyWorking.value && end == null
        ? 'Select an end date'
        : null;
    return _startError.value == null && _endError.value == null;
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final fieldsOk = _formKey.currentState?.validate() ?? false;
    final datesOk = _validateDates();
    if (!fieldsOk || !datesOk) return;

    _bloc.add(ExperienceFormSaved(_current, id: widget.experience?.id));
  }

  Future<void> _delete() async {
    final experience = widget.experience;
    if (experience == null) return;
    FocusScope.of(context).unfocus();
    final confirmed = await showDeleteExperienceSheet(context, experience);
    if (confirmed && mounted) _bloc.add(ExperienceFormDeleted(experience.id));
  }

  void _onState(BuildContext context, ExperienceFormState state) {
    switch (state.status) {
      case ExperienceFormStatus.saved:
        _hasChanges.value = false;
        AppSnackbar.success(
          title: _isEditing ? 'Experience updated' : 'Experience added',
        );
        Navigator.of(context).pop(true);
      case ExperienceFormStatus.deleted:
        _hasChanges.value = false;
        AppSnackbar.success(title: 'Position deleted');
        Navigator.of(context).pop(true);
      case ExperienceFormStatus.failure:
        final isDelete = state.action == ExperienceFormAction.delete;
        AppSnackbar.error(
          title: isDelete
              ? "Couldn't delete this position"
              : "Couldn't save your experience",
          message:
              state.failure?.message ?? 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: isDelete ? _delete : _save,
        );
      case ExperienceFormStatus.idle:
      case ExperienceFormStatus.saving:
      case ExperienceFormStatus.deleting:
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

    return BlocConsumer<ExperienceFormBloc, ExperienceFormState>(
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
                Text(_isEditing ? 'Edit experience' : 'Add experience'),
                Text(
                  'Employers use this to judge your fit',
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
                        child: ExperienceUnsavedTag(),
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
                  _roleSection(),
                  _datesSection(),
                  _detailsSection(),
                  if (_isEditing)
                    ProfileSection(
                      title: 'Manage',
                      child: DeleteExperienceButton(
                        onPressed: state.isBusy ? null : _delete,
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: ExperienceSaveBar(
            label: _isEditing ? 'Save changes' : 'Add experience',
            isSaving: state.isBusy,
            onSave: _save,
          ),
        ),
      ),
    );
  }

  Widget _roleSection() {
    return ProfileSection(
      title: 'Role',
      showDivider: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExperienceLabeledField(
            label: 'Job title',
            required: true,
            child: TextFormField(
              controller: _jobTitle,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Staff nurse'),
              validator: (v) =>
                  InputValidators.required(v, fieldName: 'a job title'),
            ),
          ),
          const SizedBox(height: 10),
          JobTitleSuggestions(controller: _jobTitle, onPicked: _pickJobTitle),
          const SizedBox(height: 14),
          ExperienceLabeledField(
            label: 'Organization',
            required: true,
            child: TextFormField(
              controller: _organization,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Hospital or clinic name',
              ),
              validator: (v) =>
                  InputValidators.required(v, fieldName: 'the organization'),
            ),
          ),
          const SizedBox(height: 14),
          ExperienceLabeledField(
            label: 'Employment type',
            child: ValueListenableBuilder<EmploymentType?>(
              valueListenable: _employmentType,
              builder: (context, type, _) => ExperiencePickerField(
                value: type?.label,
                placeholder: 'Select employment type',
                onTap: _pickEmploymentType,
                onClear: () => _employmentType.value = null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datesSection() {
    return ProfileSection(
      title: 'Dates',
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _currentlyWorking,
          _startDate,
          _endDate,
          _startError,
          _endError,
        ]),
        builder: (context, _) {
          final current = _currentlyWorking.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CurrentlyWorkingTile(
                value: current,
                onChanged: (value) {
                  _currentlyWorking.value = value;
                  if (value) _endError.value = null;
                },
              ),
              const SizedBox(height: 12),
              ExperienceFieldPair(
                first: ExperienceLabeledField(
                  label: 'Start date',
                  required: true,
                  child: ExperiencePickerField(
                    value: _formatMonth(_startDate.value),
                    placeholder: 'Month, year',
                    icon: AppIcons.calendar,
                    errorText: _startError.value,
                    onTap: _pickStart,
                  ),
                ),
                second: ExperienceLabeledField(
                  label: 'End date',
                  required: true,
                  enabled: !current,
                  child: ExperiencePickerField(
                    value: current ? 'Present' : _formatMonth(_endDate.value),
                    placeholder: 'Month, year',
                    icon: AppIcons.calendar,
                    errorText: current ? null : _endError.value,
                    onTap: current ? null : _pickEnd,
                  ),
                ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExperienceLabeledField(
            label: 'Location',
            child: TextFormField(
              controller: _location,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'City or area'),
            ),
          ),
          const SizedBox(height: 14),
          ExperienceLabeledField(
            label: 'Responsibilities',
            hint: "What you did day to day and what you're proud of.",
            child: TextFormField(
              controller: _responsibilities,
              minLines: 3,
              maxLines: 6,
              maxLength: _responsibilitiesLimit,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Managed ICU patient care for 12 beds.',
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
