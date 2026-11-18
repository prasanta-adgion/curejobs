part of 'current_plan_bloc.dart';

sealed class CurrentPlanEvent extends Equatable {
  const CurrentPlanEvent();

  @override
  List<Object?> get props => [];
}

/// First load, or a refresh (e.g. after checkout). The last loaded plan
/// stays visible while it runs.
final class CurrentPlanRequested extends CurrentPlanEvent {
  const CurrentPlanRequested();
}
