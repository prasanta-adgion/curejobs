import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../applied_application/domain/usecases/withdraw_application_usecase.dart';
import '../../domain/entities/application_detail.dart';
import '../../domain/usecases/get_application_detail_usecase.dart';

enum ApplicationDetailStatus { loading, success, failure }

class ApplicationDetailState extends Equatable {
  const ApplicationDetailState({
    this.status = ApplicationDetailStatus.loading,
    this.detail,
    this.failure,
    this.isWithdrawing = false,
  });

  final ApplicationDetailStatus status;
  final ApplicationDetail? detail;
  final Failure? failure;
  final bool isWithdrawing;

  ApplicationDetailState copyWith({
    ApplicationDetailStatus? status,
    ApplicationDetail? detail,
    Failure? failure,
    bool? isWithdrawing,
  }) => ApplicationDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    failure: failure,
    isWithdrawing: isWithdrawing ?? this.isWithdrawing,
  );

  @override
  List<Object?> get props => [status, detail, failure, isWithdrawing];
}

class ApplicationDetailCubit extends Cubit<ApplicationDetailState> {
  ApplicationDetailCubit(this._getDetail, this._withdraw)
    : super(const ApplicationDetailState());

  final GetApplicationDetailUseCase _getDetail;
  final WithdrawApplicationUseCase _withdraw;

  Future<void> load(String id) async {
    emit(state.copyWith(status: ApplicationDetailStatus.loading));
    final result = await _getDetail(id);
    if (isClosed) return;
    result.fold(
      (detail) => emit(
        state.copyWith(status: ApplicationDetailStatus.success, detail: detail),
      ),
      (failure) => emit(
        state.copyWith(
          status: ApplicationDetailStatus.failure,
          failure: failure,
        ),
      ),
    );
  }

  /// Withdraws, then reloads. Returns the failure, or null on success.
  Future<Failure?> withdraw() async {
    final detail = state.detail;
    if (detail == null || state.isWithdrawing) return null;
    emit(state.copyWith(isWithdrawing: true));
    final result = await _withdraw(detail.id);
    if (isClosed) return result.failureOrNull;
    final failure = result.failureOrNull;
    if (failure != null) {
      emit(state.copyWith(isWithdrawing: false));
      return failure;
    }
    final reloaded = await _getDetail(detail.id);
    if (isClosed) return null;
    emit(
      state.copyWith(
        isWithdrawing: false,
        status: ApplicationDetailStatus.success,
        detail: reloaded.valueOrNull,
      ),
    );
    return null;
  }
}
