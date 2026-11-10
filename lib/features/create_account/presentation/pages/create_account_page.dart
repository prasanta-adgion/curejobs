import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snackbar.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../../../../app/di/injection_container.dart';
import '../../../../core/services/document_picker_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/picked_file.dart';
import '../../../../shared/widgets/photo_source_sheet.dart';
import '../../../bottom_nav/bottom_navbar.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/bloc/categories_bloc.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../media_preview/domain/enums/media_upload_purpose.dart';
import '../../../media_preview/presentation/pick_and_upload_media.dart';
import '../../../specialization/domain/entities/specialization.dart';
import '../../../specialization/presentation/bloc/specializations_bloc.dart';
import '../../../specialization/presentation/pages/specialization_page.dart';
import '../../domain/entities/create_account_params.dart';
import '../bloc/create_account_bloc.dart';
import '../widgets/about_you_step.dart';
import '../widgets/all_done_view.dart';
import '../widgets/create_account_footer.dart';
import '../widgets/create_account_header.dart';
import '../widgets/location_step.dart';
import '../widgets/your_work_step.dart';

/// Profile setup shown after registration: three steps and a finish screen.
///
/// Nothing is saved to the API yet, and the completion percent is sample data.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  static const _totalSteps = 3;
  static const _samplePercent = 70;

  final _nameFormKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _pinCode = TextEditingController();
  final _country = TextEditingController(text: 'India');
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _area = TextEditingController();

  final _imagePicker = ImagePickerService();
  final _documentPicker = const DocumentPickerService();

  /// Shared with the picker pages.
  final _categoriesBloc = sl<CategoriesBloc>()
    ..add(const CategoriesRequested());
  final _specializationsBloc = sl<SpecializationsBloc>();
  final _createAccountBloc = sl<CreateAccountBloc>();

  /// 1 to 3 for the steps, 4 for the finish screen.
  final _step = ValueNotifier<int>(1);
  final _category = ValueNotifier<Category?>(null);
  final _specialization = ValueNotifier<Specialization?>(null);
  final _photo = ValueNotifier<PickedFile?>(null);
  final _resume = ValueNotifier<PickedFile?>(null);

  /// Finalized photo file id, sent when the profile is saved. Not shown.
  String? _photoFileId;

  bool _isDone(int step) => step > _totalSteps;

  String? get _initials {
    final letters = [_firstName.text, _lastName.text]
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .map((name) => name[0].toUpperCase())
        .join();
    return letters.isEmpty ? null : letters;
  }

  String? get _location {
    final parts = [
      _city.text,
      _state.text,
    ].map((part) => part.trim()).where((part) => part.isNotEmpty);
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _title,
      _summary,
      _pinCode,
      _country,
      _city,
      _state,
      _area,
    ]) {
      controller.dispose();
    }
    for (final notifier in <ValueNotifier<Object?>>[
      _step,
      _category,
      _specialization,
      _photo,
      _resume,
    ]) {
      notifier.dispose();
    }
    _categoriesBloc.close();
    _specializationsBloc.close();
    _createAccountBloc.close();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    final step = _step.value;
    if (step == 1 && !_nameFormKey.currentState!.validate()) return;
    if (step == _totalSteps) {
      _createAccountBloc.add(CreateAccountSubmitted(_buildParams()));
      return;
    }
    _step.value = step + 1;
  }

  //request payload
  CreateAccountParams _buildParams() {
    return CreateAccountParams(
      firstName: _firstName.text,
      lastName: _lastName.text,
      professionalTitle: _title.text,
      professionalSummary: _summary.text,
      profilePhotoFileId: _photoFileId,
      primaryCategoryId: _category.value?.id,
      primarySpecializationId: _specialization.value?.id,
      area: _area.text,
      city: _city.text,
      state: _state.text,
      country: _country.text,
      postalCode: _pinCode.text,
    );
  }

  void _onCreateAccountState(BuildContext context, CreateAccountState state) {
    switch (state.status) {
      case CreateAccountSubmitStatus.success:
        _step.value = _totalSteps + 1;
      case CreateAccountSubmitStatus.failure:
        AppSnackbar.error(
          title: "Couldn't save your profile",
          message: state.failure?.message ?? 'Try again in a moment.',
        );
      case CreateAccountSubmitStatus.initial:
      case CreateAccountSubmitStatus.submitting:
        break;
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    _step.value--;
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DashboardPage()),
      (_) => false,
    );
  }

  Future<void> _pickCategory() async {
    final state = _categoriesBloc.state;
    if (state.categories.isEmpty && !state.isLoading) {
      _categoriesBloc.add(const CategoriesRequested());
    }
    final current = _category.value;
    final picked = await Navigator.of(context).push<Category>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _categoriesBloc,
          child: CategoryPage(selectedId: current?.id),
        ),
      ),
    );
    if (picked == null || picked.id == current?.id) return;

    _specializationsBloc.add(SpecializationsRequested(picked.id));
    _category.value = picked;
    // A specialization only makes sense within its category.
    _specialization.value = null;
  }

  Future<void> _pickSpecialization() async {
    final categoryId = _category.value?.id;
    if (categoryId == null) return;

    final state = _specializationsBloc.state;
    if (state.specializations.isEmpty && !state.isLoading) {
      _specializationsBloc.add(SpecializationsRequested(categoryId));
    }
    final picked = await Navigator.of(context).push<Specialization>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _specializationsBloc,
          child: SpecializationPage(
            categoryId: categoryId,
            categoryName: _category.value?.name,
            categorySlug: _category.value?.slug,
            selectedId: _specialization.value?.id,
          ),
        ),
      ),
    );
    if (picked != null) _specialization.value = picked;
  }

  Future<void> _pickPhoto() async {
    FocusScope.of(context).unfocus();
    final current = _photo.value;
    final action = await showPhotoSourceSheet(
      context,
      photo: current == null ? null : FileImage(File(current.path)),
      initials: _initials,
      canRemove: current != null,
    );
    if (action == null || !mounted) return;

    final source = switch (action) {
      PhotoSheetAction.camera => ImageSource.camera,
      PhotoSheetAction.gallery => ImageSource.gallery,
      PhotoSheetAction.remove => null,
    };
    if (source == null) {
      _photo.value = null;
      _photoFileId = null;
      return;
    }
    final photo = await _pickAndPreview(
      () => _imagePicker.pickPhoto(source),
      purpose: MediaUploadPurpose.profilePhoto,
      pickAgainLabel: source == ImageSource.camera ? 'Retake' : 'Change',
    );
    if (photo == null) return;
    _photoFileId = photo.fileId;
    _photo.value = photo.file;
  }

  Future<void> _pickResume() async {
    final resume = await _pickAndPreview(
      _documentPicker.pickResume,
      purpose: MediaUploadPurpose.resume,
    );
    if (resume != null) _resume.value = resume.file;
  }

  Future<({PickedFile file, String fileId})?> _pickAndPreview(
    Future<PickedFile?> Function() picker, {
    required MediaUploadPurpose purpose,
    String pickAgainLabel = 'Change',
  }) {
    final name = '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
    final title = _title.text.trim();

    return pickAndUploadMedia(
      context,
      picker,
      purpose: purpose,
      pickAgainLabel: pickAgainLabel,
      name: name.isEmpty ? null : name,
      subtitle: title.isEmpty ? null : title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<CreateAccountBloc, CreateAccountState>(
        bloc: _createAccountBloc,
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onCreateAccountState,
        child: ValueListenableBuilder<int>(
          valueListenable: _step,
          builder: (context, step, _) => PopScope(
            canPop: step == 1 || _isDone(step),
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _back();
            },
            child: Scaffold(
              body: Column(
                children: [
                  _buildHeader(step),
                  Expanded(child: _buildBody(step)),
                  _buildFooter(step),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int step) {
    if (_isDone(step)) {
      final title = _title.text.trim();
      return AllDoneHeader(
        firstName: _firstName.text.trim(),
        initials: _initials,
        percent: _samplePercent,
        title: title.isEmpty ? null : title,
        location: _location,
      );
    }

    final (heading, subtitle) = switch (step) {
      1 => ('Tell us about you', 'This is what recruiters see first.'),
      2 => ('Your work', 'So we can match you with the right jobs.'),
      _ => ('Where are you based?', "We'll show you nearby jobs first."),
    };

    return CreateAccountHeader(
      step: step,
      totalSteps: _totalSteps,
      title: heading,
      subtitle: subtitle,
      onBack: step > 1 ? _back : null,
      onSkip: _goToDashboard,
    );
  }

  Widget _buildBody(int step) {
    return switch (step) {
      1 => Form(
        key: _nameFormKey,
        child: ValueListenableBuilder<PickedFile?>(
          valueListenable: _photo,
          builder: (context, photo, _) => AboutYouStep(
            firstName: _firstName,
            lastName: _lastName,
            photoPath: photo?.path,
            onUploadPhoto: _pickPhoto,
          ),
        ),
      ),
      2 => ListenableBuilder(
        listenable: Listenable.merge([_category, _specialization]),
        builder: (context, _) => YourWorkStep(
          title: _title,
          summary: _summary,
          categoryName: _category.value?.name,
          specializationName: _specialization.value?.name,
          onPickCategory: _pickCategory,
          onPickSpecialization: _pickSpecialization,
        ),
      ),
      3 => LocationStep(
        pinCode: _pinCode,
        city: _city,
        state: _state,
        area: _area,
        country: _country,
      ),
      _ => ValueListenableBuilder<PickedFile?>(
        valueListenable: _resume,
        builder: (context, resume, _) => AllDoneBody(
          resumeName: resume?.name,
          onViewMatches: _goToDashboard,
          onUploadResume: _pickResume,
        ),
      ),
    };
  }

  Widget _buildFooter(int step) {
    if (_isDone(step)) {
      return CreateAccountFooter(
        label: 'Browse jobs',
        onPressed: _goToDashboard,
      );
    }
    return BlocBuilder<CreateAccountBloc, CreateAccountState>(
      bloc: _createAccountBloc,
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        final isSaving = state.isSubmitting;
        return CreateAccountFooter(
          label: step == _totalSteps
              ? (isSaving ? 'Saving…' : 'Finish')
              : 'Continue',
          // Null disables the buttons while saving.
          onPressed: isSaving ? null : _next,
          onBack: step > 1 && !isSaving ? _back : null,
          showArrow: step == 1,
        );
      },
    );
  }
}
