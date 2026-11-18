part of 'plan_history_bloc.dart';

sealed class PlanHistoryEvent extends Equatable {
  const PlanHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// First page, or pull to refresh (keeps the list visible).
final class PlanHistoryRequested extends PlanHistoryEvent {
  const PlanHistoryRequested();
}

/// Scrolled near the end of the list, or tapped "Try again" on the footer.
final class PlanHistoryNextPageRequested extends PlanHistoryEvent {
  const PlanHistoryNextPageRequested();
}
