import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../media_preview/domain/usecases/get_file_access_url_usecase.dart';
import '../../domain/entities/organization_details.dart';
import '../../domain/usecases/get_organization_usecase.dart';

part 'organization_details_state.dart';

/// Loads an employer's profile, then its logo URL. Its jobs come from
/// `JobsBloc` with the organization id.
class OrganizationDetailsCubit extends Cubit<OrganizationDetailsState> {
  final GetOrganizationUseCase _getOrganization;
  final GetFileAccessUrlUseCase _getFileUrl;

  OrganizationDetailsCubit(this._getOrganization, this._getFileUrl)
    : super(const OrganizationDetailsState());

  /// [slug] (or id) goes in `api/v1/public/organizations/{slug}`.
  Future<void> load(String slug) async {
    if (state.status == OrganizationStatus.loading) return;
    emit(
      OrganizationDetailsState(
        status: OrganizationStatus.loading,
        organization: state.organization,
        logoUrl: state.logoUrl,
      ),
    );

    final result = await _getOrganization(slug);
    if (isClosed) return;
    final org = result.fold<OrganizationDetails?>((o) => o, (failure) {
      emit(
        OrganizationDetailsState(
          status: OrganizationStatus.failure,
          failure: failure,
        ),
      );
      return null;
    });
    if (org == null) return;

    emit(
      OrganizationDetailsState(
        status: OrganizationStatus.success,
        organization: org,
        logoUrl: state.logoUrl,
      ),
    );
    await _loadLogo(org.logoFileId);
  }

  Future<void> _loadLogo(String? fileId) async {
    if (fileId == null || fileId.isEmpty) return;
    final result = await _getFileUrl(fileId);
    if (isClosed) return;
    // A missing logo isn't worth an error; the initials stay.
    result.fold(
      (url) => emit(
        OrganizationDetailsState(
          status: state.status,
          organization: state.organization,
          logoUrl: url,
        ),
      ),
      (_) {},
    );
  }
}
