import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/certification.dart';
import '../../domain/usecases/delete_certification_usecase.dart';
import '../../domain/usecases/get_certifications_usecase.dart';

part 'certifications_event.dart';
part 'certifications_state.dart';

/// Loads the candidate's certificates and licences, and deletes from the
/// list. Adding and editing happen on the form screen.
class CertificationsBloc
    extends Bloc<CertificationsEvent, CertificationsState> {
  final GetCertificationsUseCase _getCertifications;
  final DeleteCertificationUseCase _deleteCertification;

  CertificationsBloc({
    required GetCertificationsUseCase getCertifications,
    required DeleteCertificationUseCase deleteCertification,
  }) : _getCertifications = getCertifications,
       _deleteCertification = deleteCertification,
       super(const CertificationsState()) {
    on<CertificationsRequested>(_onRequested);
    on<CertificationDeleted>(_onDeleted);
  }

  Future<void> _onRequested(
    CertificationsRequested event,
    Emitter<CertificationsState> emit,
  ) async {
    if (state.status == CertificationsStatus.loading) return;
    emit(state.copyWith(status: CertificationsStatus.loading));

    final result = await _getCertifications();

    result.fold(
      (items) => emit(
        state.copyWith(status: CertificationsStatus.success, items: items),
      ),
      (failure) => emit(
        state.copyWith(status: CertificationsStatus.failure, failure: failure),
      ),
    );
  }

  /// Keeps the row with a spinner until the server confirms.
  Future<void> _onDeleted(
    CertificationDeleted event,
    Emitter<CertificationsState> emit,
  ) async {
    final item = event.certification;
    if (state.isDeleting(item)) return;
    emit(state.copyWith(deletingIds: {...state.deletingIds, item.id}));

    final result = await _deleteCertification(item.id);
    final remaining = {...state.deletingIds}..remove(item.id);

    result.fold(
      (_) => emit(
        state.copyWith(
          items: [...state.items]..removeWhere((c) => c.id == item.id),
          deletingIds: remaining,
          deleted: true,
        ),
      ),
      (failure) =>
          emit(state.copyWith(deletingIds: remaining, actionFailure: failure)),
    );
  }
}
