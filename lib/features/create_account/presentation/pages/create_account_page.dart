import 'dart:io';

import 'package:flutter/material.dart';
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
  static const _countries = ['India'];

  final _nameFormKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _pinCode = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _area = TextEditingController();

  final _imagePicker = ImagePickerService();
  final _documentPicker = const DocumentPickerService();

  /// Shared with the picker pages.
  final _categoriesBloc = sl<CategoriesBloc>()
    ..add(const CategoriesRequested());
  final _specializationsBloc = sl<SpecializationsBloc>();

  /// 1 to 3 for the steps, 4 for the finish screen.
  int _step = 1;
  Category? _category;
  Specialization? _specialization;
  String? _country = _countries.first;
  PickedFile? _photo;
  PickedFile? _resume;

  /// Finalized file ids, for when the profile is saved.
  String? _photoFileId;
  String? _resumeFileId;

  bool get _isDone => _step > _totalSteps;

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
      _city,
      _state,
      _area,
    ]) {
      controller.dispose();
    }
    _categoriesBloc.close();
    _specializationsBloc.close();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step == 1 && !_nameFormKey.currentState!.validate()) return;
    setState(() => _step++);
  }

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() => _step--);
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
    final picked = await Navigator.of(context).push<Category>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _categoriesBloc,
          child: CategoryPage(selectedId: _category?.id),
        ),
      ),
    );
    if (picked == null || picked.id == _category?.id) return;

    _specializationsBloc.add(SpecializationsRequested(picked.id));
    setState(() {
      _category = picked;
      // A specialization only makes sense within its category.
      _specialization = null;
    });
  }

  Future<void> _pickSpecialization() async {
    final categoryId = _category?.id;
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
            selectedId: _specialization?.id,
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _specialization = picked);
  }

  Future<void> _pickPhoto() async {
    FocusScope.of(context).unfocus();
    final current = _photo;
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
      setState(() {
        _photo = null;
        _photoFileId = null;
      });
      return;
    }
    final photo = await _pickAndPreview(
      () => _imagePicker.pickPhoto(source),
      purpose: MediaUploadPurpose.profilePhoto,
      pickAgainLabel: source == ImageSource.camera ? 'Retake' : 'Change',
    );
    if (photo == null) return;
    setState(() {
      _photo = photo.file;
      _photoFileId = photo.fileId;
    });
  }

  Future<void> _pickResume() async {
    final resume = await _pickAndPreview(
      _documentPicker.pickResume,
      purpose: MediaUploadPurpose.resume,
    );
    if (resume == null) return;
    setState(() {
      _resume = resume.file;
      _resumeFileId = resume.fileId;
    });
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
    final title = _title.text.trim();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: _step == 1 || _isDone,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          body: Column(
            children: [
              if (_isDone)
                AllDoneHeader(
                  firstName: _firstName.text.trim(),
                  initials: _initials,
                  percent: _samplePercent,
                  title: title.isEmpty ? null : title,
                  location: _location,
                )
              else
                _buildHeader(),
              Expanded(child: _buildBody()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final (heading, subtitle) = switch (_step) {
      1 => ('Tell us about you', 'This is what recruiters see first.'),
      2 => ('Your work', 'So we can match you with the right jobs.'),
      _ => ('Where are you based?', "We'll show you nearby jobs first."),
    };

    return CreateAccountHeader(
      step: _step,
      totalSteps: _totalSteps,
      title: heading,
      subtitle: subtitle,
      onBack: _step > 1 ? _back : null,
      onSkip: _goToDashboard,
    );
  }

  Widget _buildBody() {
    return switch (_step) {
      1 => Form(
        key: _nameFormKey,
        child: AboutYouStep(
          firstName: _firstName,
          lastName: _lastName,
          photoPath: _photo?.path,
          onUploadPhoto: _pickPhoto,
        ),
      ),
      2 => YourWorkStep(
        title: _title,
        summary: _summary,
        categoryName: _category?.name,
        specializationName: _specialization?.name,
        onPickCategory: _pickCategory,
        onPickSpecialization: _pickSpecialization,
      ),
      3 => LocationStep(
        pinCode: _pinCode,
        city: _city,
        state: _state,
        area: _area,
        country: _country,
        countries: _countries,
        onCountryChanged: (value) => setState(() => _country = value),
      ),
      _ => AllDoneBody(
        resumeName: _resume?.name,
        onViewMatches: _goToDashboard,
        onUploadResume: _pickResume,
      ),
    };
  }

  Widget _buildFooter() {
    if (_isDone) {
      return CreateAccountFooter(
        label: 'Browse jobs',
        onPressed: _goToDashboard,
      );
    }
    return CreateAccountFooter(
      label: _step == _totalSteps ? 'Finish' : 'Continue',
      onPressed: _next,
      onBack: _step > 1 ? _back : null,
      showArrow: _step == 1,
    );
  }
}
