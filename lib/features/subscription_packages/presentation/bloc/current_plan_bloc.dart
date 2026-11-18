import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/usecases/get_current_plan_usecase.dart';

part 'current_plan_event.dart';
part 'current_plan_state.dart';

/// Loads the user's current plan. Keeps the last loaded plan visible while
/// refreshing or after a failed refresh.
class CurrentPlanBloc extends Bloc<CurrentPlanEvent, CurrentPlanState> {
  CurrentPlanBloc(this._getCurrentPlan) : super(const CurrentPlanState()) {
    on<CurrentPlanRequested>(_onRequested);
  }

  final GetCurrentPlanUseCase _getCurrentPlan;

  Future<void> _onRequested(
    CurrentPlanRequested event,
    Emitter<CurrentPlanState> emit,
  ) async {
    if (state.subscription == null) emit(const CurrentPlanState());
    final result = await _getCurrentPlan();
    result.fold(
      (s) => emit(
        CurrentPlanState(status: CurrentPlanStatus.success, subscription: s),
      ),
      (f) => emit(
        CurrentPlanState(
          status: CurrentPlanStatus.failure,
          subscription: state.subscription,
          failure: f,
        ),
      ),
    );
  }
}
