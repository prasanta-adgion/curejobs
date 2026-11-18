part of 'current_plan_bloc.dart';

enum CurrentPlanStatus { loading, success, failure }

class CurrentPlanState extends Equatable {
  const CurrentPlanState({
    this.status = CurrentPlanStatus.loading,
    this.subscription,
    this.failure,
  });

  final CurrentPlanStatus status;
  final CurrentSubscription? subscription;
  final Failure? failure;

  @override
  List<Object?> get props => [status, subscription, failure];
}
