part of 'payments_bloc.dart';

sealed class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object?> get props => [];
}

/// First load or pull to refresh.
final class PaymentsRequested extends PaymentsEvent {
  const PaymentsRequested();
}
