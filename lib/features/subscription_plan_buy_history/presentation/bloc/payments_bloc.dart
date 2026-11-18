import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/usecases/get_payments_usecase.dart';

part 'payments_event.dart';
part 'payments_state.dart';

/// Loads the payment list for the Payments tab.
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  PaymentsBloc(this._getPayments) : super(const PaymentsState()) {
    on<PaymentsRequested>(_onRequested);
  }

  final GetPaymentsUseCase _getPayments;

  Future<void> _onRequested(
    PaymentsRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    // Keep the current list visible while refreshing.
    if (state.items.isEmpty) emit(const PaymentsState());
    final result = await _getPayments();
    result.fold(
      (items) {
        final sorted = [...items]..sort((a, b) => b.date.compareTo(a.date));
        emit(PaymentsState(status: PaymentsStatus.success, items: sorted));
      },
      (f) => emit(
        PaymentsState(
          status: PaymentsStatus.failure,
          items: state.items,
          failure: f,
        ),
      ),
    );
  }
}
