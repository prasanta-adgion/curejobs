import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/candidate_verification.dart';
import '../../domain/entities/verification_document_type.dart';
import '../../domain/entities/verification_eligibility.dart';
import '../../domain/entities/verification_request_detail.dart';
import '../../domain/usecases/add_verification_document_usecase.dart';
import '../../domain/usecases/create_verification_request_usecase.dart';
import '../../domain/usecases/delete_verification_document_usecase.dart';
import '../../domain/usecases/get_document_types_usecase.dart';
import '../../domain/usecases/get_my_verification_usecase.dart';
import '../../domain/usecases/get_verification_eligibility_usecase.dart';
import '../../domain/usecases/get_verification_request_detail_usecase.dart';
import '../../domain/usecases/submit_for_review_usecase.dart';
import '../models/types_load.dart';
import '../widgets/documents/added_document.dart';

part 'verification_event.dart';
part 'verification_state.dart';

/// "Get verified" flow: Plan → Documents → Review → Badge.
///
/// 1. [VerificationLoadRequested] loads eligibility and `verifications/me`
///    together, then the request detail; together they decide the step.
/// 2. [VerificationStartRequested] starts a request (if none) and loads the
///    document types, which show the upload form.
/// 3. [VerificationDocumentAttached] / [VerificationDocumentDeleted] change
///    the attached document; [VerificationSubmitRequested] sends it.
class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc({
    required GetVerificationEligibilityUseCase getEligibility,
    required GetMyVerificationUseCase getMyVerification,
    required GetVerificationRequestDetailUseCase getRequestDetail,
    required GetDocumentTypesUseCase getDocumentTypes,
    required CreateVerificationRequestUseCase createRequest,
    required AddVerificationDocumentUseCase addDocument,
    required DeleteVerificationDocumentUseCase deleteDocument,
    required SubmitForReviewUseCase submitForReview,
  }) : _getEligibility = getEligibility,
       _getMyVerification = getMyVerification,
       _getRequestDetail = getRequestDetail,
       _getDocumentTypes = getDocumentTypes,
       _createRequest = createRequest,
       _addDocument = addDocument,
       _deleteDocument = deleteDocument,
       _submitForReview = submitForReview,
       super(const VerificationState()) {
    on<VerificationLoadRequested>((_, emit) => _load(emit));
    on<VerificationStartRequested>(_onStart);
    on<VerificationDocumentAttached>(_onAttach);
    on<VerificationDocumentDeleted>(_onDelete);
    on<VerificationSubmitRequested>(_onSubmit);
  }

  final GetVerificationEligibilityUseCase _getEligibility;
  final GetMyVerificationUseCase _getMyVerification;
  final GetVerificationRequestDetailUseCase _getRequestDetail;
  final GetDocumentTypesUseCase _getDocumentTypes;
  final CreateVerificationRequestUseCase _createRequest;
  final AddVerificationDocumentUseCase _addDocument;
  final DeleteVerificationDocumentUseCase _deleteDocument;
  final SubmitForReviewUseCase _submitForReview;

  static const _noRequest = 'No verification request found.';

  // ── Loading ───────────────────────────────────────────────────────────────

  /// Round 1: eligibility (required) and `verifications/me` in parallel.
  /// Round 2: the request detail, the source of truth for document status,
  /// so the first step shown is already right.
  Future<void> _load(Emitter<VerificationState> emit) async {
    emit(state.copyWith(status: VerificationStatus.loading));

    final myFuture = _getMyVerification();
    final eligibility = await _getEligibility();
    final my = (await myFuture).valueOrNull;

    final requestId =
        my?.currentRequest?.id ??
        state.createdRequestId ??
        eligibility.valueOrNull?.currentRequest?.id;
    final detail = await _fetchRequest(requestId);

    emit(
      eligibility.fold(
        // Handle success
        (e) => state.copyWith(
          status: VerificationStatus.ready,
          eligibility: e,
          myVerification: () => my,
          request: detail,
        ),
        // Handle failure
        (fail) => state.copyWith(
          status: VerificationStatus.failure,
          failure: fail,
          myVerification: () => my,
          request: detail,
        ),
      ),
    );

    // The review step names the sent documents, and a started request shows
    // the upload form straight away: both need the types without a tap.
    final step = state.step;
    if (step == VerificationStep.review ||
        (step == VerificationStep.documents && state.alreadyStarted)) {
      await _loadDocumentTypes(emit);
    }
  }

  /// `GET verifications/{id}`; null when there is no request or it failed
  /// (the step then falls back to eligibility).
  Future<VerificationRequestDetail?> _fetchRequest(String? requestId) async {
    if (requestId == null) return null;
    final result = await _getRequestDetail(verificationId: requestId);
    return result.valueOrNull;
  }

  /// Loads the document types once; starts no request.
  Future<void> _loadDocumentTypes(Emitter<VerificationState> emit) async {
    if (state.typesLoad.isLoading || state.typesLoad.isLoaded) return;
    emit(state.copyWith(typesLoad: const TypesLoad.loading()));
    final result = await _getDocumentTypes();
    emit(
      result.fold(
        (types) => state.copyWith(
          documentTypes: types,
          typesLoad: const TypesLoad.loaded(),
        ),
        (f) => state.copyWith(typesLoad: TypesLoad.failed(f.message)),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Starts a request unless one is already started, and loads the document
  /// types at the same time.
  Future<void> _onStart(
    VerificationStartRequested event,
    Emitter<VerificationState> emit,
  ) async {
    if (state.typesLoad.isLoading) return;
    if (state.eligibility?.eligible == false) {
      emit(
        state.copyWith(
          typesLoad: const TypesLoad.failed(
            "You're not eligible for verification right now.",
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(typesLoad: const TypesLoad.loading()));

    final typesFuture = _getDocumentTypes();
    final created = state.alreadyStarted ? null : await _createRequest();
    final types = await typesFuture;

    final failure = types.failureOrNull ?? created?.failureOrNull;
    if (failure != null) {
      emit(state.copyWith(typesLoad: TypesLoad.failed(failure.message)));
      return;
    }
    emit(
      state.copyWith(
        createdRequestId: created?.valueOrNull?.id,
        documentTypes: types.valueOrNull,
        typesLoad: const TypesLoad.loaded(),
      ),
    );
  }

  /// Attaches the uploaded file (`POST verifications/{id}/documents`), then
  /// reloads the request so the document shows and Submit turns on.
  Future<void> _onAttach(
    VerificationDocumentAttached event,
    Emitter<VerificationState> emit,
  ) async {
    final requestId = state.requestId;
    if (requestId == null) {
      emit(state.copyWith(message: _noRequest));
      return event.result.complete(false);
    }
    final doc = event.document;
    final result = await _addDocument(
      verificationId: requestId,
      documentTypeId: doc.type.id,
      fileId: doc.fileId,
    );
    final failure = result.failureOrNull;
    if (failure != null) {
      emit(state.copyWith(message: failure.message));
      return event.result.complete(false);
    }

    final detail = await _fetchRequest(requestId);
    emit(
      state.copyWith(
        fileNames: {...state.fileNames, doc.fileId: doc.file.name},
        request: detail,
      ),
    );
    event.result.complete(true);
  }

  /// `DELETE verifications/{id}/documents/{documentId}`, then a full reload:
  /// deleting can change the step (e.g. review → documents).
  Future<void> _onDelete(
    VerificationDocumentDeleted event,
    Emitter<VerificationState> emit,
  ) async {
    final doc = event.document;
    if (state.deletingIds.contains(doc.id)) return;
    final requestId = state.requestId;
    if (requestId == null) return emit(state.copyWith(message: _noRequest));

    emit(state.copyWith(deletingIds: {...state.deletingIds, doc.id}));
    final result = await _deleteDocument(
      verificationId: requestId,
      documentId: doc.id,
    );
    final failure = result.failureOrNull;
    if (failure == null) {
      emit(state.copyWith(fileNames: {...state.fileNames}..remove(doc.fileId)));
      await _load(emit);
    }
    emit(
      state.copyWith(
        deletingIds: {...state.deletingIds}..remove(doc.id),
        message: failure?.message,
      ),
    );
  }

  /// `POST verifications/{id}/submit`, then a reload, which moves on to the
  /// review step.
  Future<void> _onSubmit(
    VerificationSubmitRequested event,
    Emitter<VerificationState> emit,
  ) async {
    final requestId = state.requestId;
    if (requestId == null || state.submitting) return;

    emit(state.copyWith(submitting: true));
    final result = await _submitForReview(verificationId: requestId);
    emit(
      result.fold(
        (detail) => state.copyWith(submitting: false, request: detail),
        (f) => state.copyWith(submitting: false, message: f.message),
      ),
    );
    if (result.failureOrNull == null) await _load(emit);
  }
}
