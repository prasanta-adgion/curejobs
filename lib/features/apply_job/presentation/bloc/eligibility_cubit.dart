import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/application_eligibility.dart';
import '../../domain/usecases/get_application_eligibility_usecase.dart';

enum EligibilityLoadStatus { loading, success, failure }

class EligibilityState extends Equatable {
  const EligibilityState({
    this.status = EligibilityLoadStatus.loading,
    this.eligibility,
    this.failure,
  });

  final EligibilityLoadStatus status;
  final ApplicationEligibility? eligibility;
  final Failure? failure;

  @override
  List<Object?> get props => [status, eligibility, failure];
}

class EligibilityCubit extends Cubit<EligibilityState> {
  EligibilityCubit(this._getEligibility) : super(const EligibilityState());

  final GetApplicationEligibilityUseCase _getEligibility;

  Future<void> load(String jobId) async {
    emit(const EligibilityState());
    final result = await _getEligibility(jobId);
    if (isClosed) return;
    result.fold(
      (e) => emit(
        EligibilityState(status: EligibilityLoadStatus.success, eligibility: e),
      ),
      (f) => emit(
        EligibilityState(status: EligibilityLoadStatus.failure, failure: f),
      ),
    );
  }
}
