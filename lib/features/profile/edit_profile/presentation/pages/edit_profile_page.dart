import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di/injection_container.dart';
import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../core/utils/input_validators.dart';
import '../../../../category/domain/entities/category.dart';
import '../../../../category/presentation/bloc/categories_bloc.dart';
import '../../../../category/presentation/pages/category_page.dart';
import '../../../../specialization/domain/entities/specialization.dart';
import '../../../../specialization/presentation/bloc/specializations_bloc.dart';
import '../../../../specialization/presentation/pages/specialization_page.dart';
import '../../../domain/entities/candidate.dart';
import '../models/profile_edit_data.dart';
import '../../../shared/widgets/profile_section.dart';

/// Form to change the candidate's photo, name, work details, summary and
/// location. UI only: saving and photo upload are left to the caller.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.candidate,
    this.onSave,
    this.onUploadPhoto,
    this.onRemovePhoto,
    this.onUseCurrentLocation,
  });

  final Candidate candidate;

  /// Saves the form. Return normally on success (the page closes) or throw
  /// to keep the page open and show the message.
  final Future<void> Function(ProfileEditData data)? onSave;
  final VoidCallback? onUploadPhoto;
  final VoidCallback? onRemovePhoto;
  final VoidCallback? onUseCurrentLocation;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _summaryLimit = 500;

  final _formKey = GlobalKey<FormState>();
  late final ProfileEditData _initial = ProfileEditData.fromCandidate(
    widget.candidate,
  );

  late final _firstName = TextEditingController(text: _initial.firstName);
  late final _lastName = TextEditingController(text: _initial.lastName);
  late final _title = TextEditingController(text: _initial.professionalTitle);
  late final _summary = TextEditingController(
    text: _initial.professionalSummary,
  );
  late final _address = TextEditingController(text: _initial.address);
  late final _city = TextEditingController(text: _initial.city);
  late final _state = TextEditingController(text: _initial.state);
  late final _country = TextEditingController(text: _initial.country);
  late final _postalCode = TextEditingController(text: _initial.postalCode);
  late String? _categoryId = _initial.categoryId;
  late String? _specializationId = _initial.specializationId;

  late final List<TextEditingController> _controllers = [
    _firstName,
    _lastName,
    _title,
    _summary,
    _address,
    _city,
    _state,
    _country,
    _postalCode,
  ];

  final _hasChanges = ValueNotifier(false);
  final _isSaving = ValueNotifier(false);

  /// Shared with the category screen. Loaded here so the saved category's
  /// name can be shown on the form.
  final _categoriesBloc = sl<CategoriesBloc>()
    ..add(const CategoriesRequested());

  /// Shared with the specialization screen, for the chosen category.
  final _specializationsBloc = sl<SpecializationsBloc>();

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_updateHasChanges);
    }
    final categoryId = _categoryId;
    if (categoryId != null) {
      _specializationsBloc.add(SpecializationsRequested(categoryId));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _hasChanges.dispose();
    _isSaving.dispose();
    _categoriesBloc.close();
    _specializationsBloc.close();
    super.dispose();
  }

  ProfileEditData get _current => ProfileEditData(
    firstName: _firstName.text.trim(),
    lastName: _lastName.text.trim(),
    professionalTitle: _title.text.trim(),
    professionalSummary: _summary.text.trim(),
    address: _address.text.trim(),
    city: _city.text.trim(),
    state: _state.text.trim(),
    country: _country.text.trim(),
    postalCode: _postalCode.text.trim(),
    categoryId: _categoryId,
    specializationId: _specializationId,
  );

  void _updateHasChanges() => _hasChanges.value = _current != _initial;

  Future<void> _pickCategory() async {
    // Try again if the first load failed.
    if (_categoriesBloc.state.status == CategoriesStatus.failure) {
      _categoriesBloc.add(const CategoriesRequested());
    }
    final picked = await Navigator.of(context).push<Category>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _categoriesBloc,
          child: CategoryPage(selectedId: _categoryId),
        ),
      ),
    );
    if (picked == null || picked.id == _categoryId) return;
    setState(() {
      _categoryId = picked.id;
      // A specialization only makes sense within its category.
      _specializationId = null;
    });
    _specializationsBloc.add(SpecializationsRequested(picked.id));
    _updateHasChanges();
  }

  Future<void> _pickSpecialization() async {
    final categoryId = _categoryId;
    if (categoryId == null) return;
    // Try again if the last load failed.
    if (_specializationsBloc.state.status == SpecializationsStatus.failure) {
      _specializationsBloc.add(SpecializationsRequested(categoryId));
    }
    final picked = await Navigator.of(context).push<Specialization>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _specializationsBloc,
          child: SpecializationPage(
            categoryId: categoryId,
            selectedId: _specializationId,
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _specializationId = picked.id);
    _updateHasChanges();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final onSave = widget.onSave;
    if (onSave == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saving isn't available yet.")),
      );
      return;
    }

    _isSaving.value = true;
    try {
      await onSave(_current);
      if (!mounted) return;
      _hasChanges.value = false;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't save your profile. Try again.")),
      );
    } finally {
      if (mounted) _isSaving.value = false;
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

    return ValueListenableBuilder<bool>(
      valueListenable: _hasChanges,
      builder: (context, hasChanges, child) => PopScope(
        canPop: !hasChanges,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmDiscard();
        },
        child: child!,
      ),
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit profile'),
              Text(
                'This is what employers see first',
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
                      child: _UnsavedTag(),
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _PhotoSection(
                  initials: widget.candidate.initials,
                  hasPhoto: widget.candidate.profilePhotoFileId != null,
                  onUpload: widget.onUploadPhoto,
                  onRemove: widget.onRemovePhoto,
                ),
                ProfileSection(
                  title: 'Basic details',
                  child: _Pair(
                    first: _LabeledField(
                      label: 'First name',
                      required: true,
                      child: TextFormField(
                        controller: _firstName,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.givenName],
                        validator: (v) => InputValidators.required(
                          v,
                          fieldName: 'first name',
                        ),
                      ),
                    ),
                    second: _LabeledField(
                      label: 'Last name',
                      required: true,
                      child: TextFormField(
                        controller: _lastName,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.familyName],
                        validator: (v) =>
                            InputValidators.required(v, fieldName: 'last name'),
                      ),
                    ),
                  ),
                ),
                ProfileSection(
                  title: 'Your work',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LabeledField(
                        label: 'Professional title',
                        required: true,
                        hint: 'Shown under your name, e.g. Staff nurse, ICU',
                        child: TextFormField(
                          controller: _title,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Staff nurse, ICU',
                          ),
                          validator: (v) => InputValidators.required(
                            v,
                            fieldName: 'your professional title',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _LabeledField(
                        label: 'Category',
                        child: BlocBuilder<CategoriesBloc, CategoriesState>(
                          bloc: _categoriesBloc,
                          builder: (context, state) => _PickerField(
                            value: _categoryName(state.categories),
                            placeholder: 'Select Category',
                            onTap: _pickCategory,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _LabeledField(
                        label: 'Specialization',
                        child:
                            BlocBuilder<
                              SpecializationsBloc,
                              SpecializationsState
                            >(
                              bloc: _specializationsBloc,
                              builder: (context, state) => _PickerField(
                                value: _specializationName(
                                  state.specializations,
                                ),
                                placeholder: _categoryId == null
                                    ? 'Select Category first'
                                    : 'Select Specialization',
                                // Stays disabled until a category is chosen.
                                onTap: _categoryId == null
                                    ? null
                                    : _pickSpecialization,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                ProfileSection(
                  title: 'About you',
                  child: _LabeledField(
                    label: 'Professional summary',
                    hint:
                        'Two or three lines on your experience and the role '
                        'you want.',
                    hintAbove: true,
                    child: TextFormField(
                      controller: _summary,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: _summaryLimit,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText:
                            'ICU nurse with 4 years in cardiac care, looking '
                            'for a senior role.',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ),
                ProfileSection(
                  title: 'Location',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Helps us show jobs near you.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: 'Address',
                        child: TextFormField(
                          controller: _address,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [
                            AutofillHints.streetAddressLine1,
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Area or street',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Pair(
                        first: _LabeledField(
                          label: 'City',
                          required: true,
                          child: TextFormField(
                            controller: _city,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.addressCity],
                            validator: (v) => InputValidators.required(
                              v,
                              fieldName: 'a city',
                            ),
                          ),
                        ),
                        second: _LabeledField(
                          label: 'PIN code',
                          child: TextFormField(
                            controller: _postalCode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.postalCode],
                            maxLength: 6,
                            buildCounter: _noCounter,
                            validator: _validatePostalCode,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Pair(
                        first: _LabeledField(
                          label: 'State',
                          required: true,
                          child: TextFormField(
                            controller: _state,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.addressState],
                            validator: (v) => InputValidators.required(
                              v,
                              fieldName: 'a state',
                            ),
                          ),
                        ),
                        second: _LabeledField(
                          label: 'Country',
                          required: true,
                          child: TextFormField(
                            controller: _country,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.countryName],
                            validator: (v) => InputValidators.required(
                              v,
                              fieldName: 'a country',
                            ),
                          ),
                        ),
                      ),
                      if (widget.onUseCurrentLocation != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: widget.onUseCurrentLocation,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                            icon: const Icon(
                              Icons.my_location_rounded,
                              size: 18,
                            ),
                            label: const Text('Use my current location'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _SaveBar(isSaving: _isSaving, onSave: _save),
      ),
    );
  }

  String? _categoryName(List<Category> categories) {
    for (final category in categories) {
      if (category.id == _categoryId) return category.name;
    }
    return null;
  }

  String? _specializationName(List<Specialization> specializations) {
    for (final specialization in specializations) {
      if (specialization.id == _specializationId) return specialization.name;
    }
    return null;
  }

  static String? _validatePostalCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return null;
    if (!RegExp(r'^\d{6}$').hasMatch(code)) return 'Enter 6 digits';
    return null;
  }

  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.initials,
    required this.hasPhoto,
    this.onUpload,
    this.onRemove,
  });

  final String initials;
  final bool hasPhoto;
  final VoidCallback? onUpload;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkPrimaryContainer,
                ),
                child: Text(
                  initials,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: scheme.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 13,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: onUpload,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.primary,
                        side: BorderSide(color: scheme.primary),
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: Text(hasPhoto ? 'Change photo' : 'Upload photo'),
                    ),
                    if (hasPhoto) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onRemove,
                        tooltip: 'Remove photo',
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: scheme.outlineVariant),
                          ),
                        ),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'PNG, JPG or WEBP, up to 5 MB. A clear face photo works '
                  'best.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label above a field, with an optional red * and a hint line.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.required = false,
    this.hint,
    this.hintAbove = false,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? hint;
  final bool hintAbove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hintText = hint == null
        ? null
        : Text(
            hint!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: scheme.error),
                ),
            ],
          ),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (hintAbove && hintText != null) ...[
          hintText,
          const SizedBox(height: 8),
        ],
        child,
        if (!hintAbove && hintText != null) ...[
          const SizedBox(height: 6),
          hintText,
        ],
      ],
    );
  }
}

/// Two fields side by side.
class _Pair extends StatelessWidget {
  const _Pair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }
}

/// Looks like a text field; opens a list of options when tapped.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.placeholder,
    this.onTap,
  });

  final String? value;
  final String placeholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          hintText: placeholder,
          enabled: enabled,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled ? scheme.onSurfaceVariant : scheme.outline,
          ),
        ),
        child: value == null
            ? null
            : Text(value!, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}

class _UnsavedTag extends StatelessWidget {
  const _UnsavedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Unsaved',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFFB45309),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "Save changes" pinned to the bottom, above the keyboard.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.isSaving, this.onSave});

  final ValueNotifier<bool> isSaving;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: isSaving,
            builder: (context, saving, _) => SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: saving ? null : onSave,
                child: saving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Saving…'),
                        ],
                      )
                    : const Text('Save changes'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
