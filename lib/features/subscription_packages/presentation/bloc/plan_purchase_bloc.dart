import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_current_plan_usecase.dart';
import '../../domain/usecases/start_plan_purchase_usecase.dart';

part 'plan_purchase_event.dart';
part 'plan_purchase_state.dart';

/// Buys a paid plan through Razorpay:
///
/// 1. `POST purchases` (with an Idempotency-Key) creates a PENDING purchase.
/// 2. `POST purchases/{id}/payments/razorpay/subscription` returns checkout
///    options; the page opens Razorpay.
/// 3. On Razorpay success, `POST payments/razorpay/verify` checks the
///    signature server-side and activates the plan. If verify can't confirm
///    (network error, missing fields, not yet ACTIVE), `subscriptions/me` is
///    polled instead, since the webhook may still activate it.
class PlanPurchaseBloc extends Bloc<PlanPurchaseEvent, PlanPurchaseState> {
  PlanPurchaseBloc(
    this._createPurchase,
    this._createRazorpaySubscription,
    this._verifyPayment,
    this._selectPlan,
    this._getCurrentPlan, {
    Uuid uuid = const Uuid(),
    this.pollInterval = const Duration(seconds: 2),
    this.maxPollAttempts = 15,
  }) : _uuid = uuid,
       super(const PlanPurchaseState()) {
    // Extra taps while a purchase is starting are dropped.
    on<PlanPurchaseStarted>(_onStarted, transformer: droppable());
    on<PlanCheckoutOpened>(_onCheckoutOpened);
    on<PlanPaymentSucceeded>(_onSucceeded, transformer: droppable());
    on<PlanPaymentFailed>(_onFailed);
    on<PlanPaymentExternalWallet>(_onExternalWallet, transformer: droppable());
    on<PlanPurchaseStatusRechecked>(_onRechecked, transformer: droppable());
    on<PlanPurchaseReset>((_, emit) => emit(const PlanPurchaseState()));
  }

  final CreatePurchaseUseCase _createPurchase;
  final CreateRazorpaySubscriptionUseCase _createRazorpaySubscription;
  final VerifyRazorpayPaymentUseCase _verifyPayment;
  final SelectPlanUseCase _selectPlan;
  final GetCurrentPlanUseCase _getCurrentPlan;
  final Uuid _uuid;
  final Duration pollInterval;
  final int maxPollAttempts;

  /// The attempt in progress. Kept so a retry for the same billing option
  /// reuses the idempotency key and purchase instead of creating new ones.
  _Attempt? _attempt;

  Future<void> _onStarted(
    PlanPurchaseStarted event,
    Emitter<PlanPurchaseState> emit,
  ) async {
    if (state.isBusy) return;
    final package = event.package;

    if (package.isFree) {
      emit(_fail('This plan is free and needs no payment.'));
      return;
    }
    // Same option whose amount the plans screen shows.
    final option = package.billingOption;
    if (option == null || !package.purchaseAvailable) {
      emit(_fail('${package.name} is not available for purchase right now.'));
      return;
    }

    emit(
      PlanPurchaseState(
        status: PlanPurchaseStatus.creating,
        planName: package.name,
      ),
    );

    // Same billing option as the last unfinished attempt → retry it.
    final previous = _attempt;
    final attempt = previous != null && previous.billingOptionId == option.id
        ? previous
        : _Attempt(
            billingOptionId: option.id,
            packageId: package.id,
            idempotencyKey: _uuid.v4(),
          );
    _attempt = attempt;

    if (attempt.purchaseId == null) {
      final result = await _createPurchase(
        billingOptionId: option.id,
        idempotencyKey: attempt.idempotencyKey,
      );
      final purchase = result.valueOrNull;
      if (purchase == null) {
        emit(_fail(_messageFor(result.failureOrNull)));
        return;
      }
      if (purchase.id.isEmpty) {
        emit(_fail("Couldn't start the payment. Please try again."));
        return;
      }
      attempt.purchaseId = purchase.id;
    }

    final result = await _createRazorpaySubscription(attempt.purchaseId!);
    final checkout = result.valueOrNull;
    if (checkout == null) {
      emit(_fail(_messageFor(result.failureOrNull)));
      return;
    }
    if (checkout.keyId.isEmpty || checkout.subscriptionId.isEmpty) {
      emit(_fail("Couldn't start the payment. Please try again."));
      return;
    }
    attempt.subscriptionId = checkout.subscriptionId;

    // Checkout must show the selected plan's amount. Use the server's amount
    // when it sends one, otherwise the selected billing option's.
    final amountMinor = checkout.amountMinor > 0
        ? checkout.amountMinor
        : option.amountMinor;
    final currency = checkout.currency.isNotEmpty
        ? checkout.currency
        : option.currency;

    emit(
      state.copyWith(
        status: PlanPurchaseStatus.checkoutReady,
        checkout: RazorpayCheckout(
          purchaseId: checkout.purchaseId.isNotEmpty
              ? checkout.purchaseId
              : attempt.purchaseId!,
          keyId: checkout.keyId,
          subscriptionId: checkout.subscriptionId,
          name: checkout.name.isNotEmpty ? checkout.name : package.name,
          description: checkout.description.isNotEmpty
              ? checkout.description
              : package.description,
          amountMinor: amountMinor,
          currency: currency,
        ),
      ),
    );
  }

  void _onCheckoutOpened(
    PlanCheckoutOpened event,
    Emitter<PlanPurchaseState> emit,
  ) {
    if (state.status == PlanPurchaseStatus.checkoutReady) {
      emit(state.copyWith(status: PlanPurchaseStatus.inCheckout));
    }
  }

  Future<void> _onSucceeded(
    PlanPaymentSucceeded event,
    Emitter<PlanPurchaseState> emit,
  ) async {
    final returned = event.subscriptionId;
    final attempt = _attempt;
    if (attempt != null && returned != null && returned.isNotEmpty) {
      attempt.subscriptionId ??= returned;
    }

    final purchaseId = attempt?.purchaseId;
    final subscriptionId = (returned != null && returned.isNotEmpty)
        ? returned
        : attempt?.subscriptionId;
    final paymentId = event.paymentId;
    final signature = event.signature;
    print('payment success'); // need to check here
    if (purchaseId != null &&
        subscriptionId != null &&
        paymentId != null &&
        paymentId.isNotEmpty &&
        signature != null &&
        signature.isNotEmpty) {
      emit(state.copyWith(status: PlanPurchaseStatus.verifying));
      final result = await _verifyPayment(
        purchaseId: purchaseId,
        paymentId: paymentId,
        subscriptionId: subscriptionId,
        signature: signature,
      );
      if (isClosed) return;

      final verified = result.valueOrNull;
      if (verified != null && verified.isActive) {
        await _complete(emit, attempt);
        return;
      }

      // A 4xx means the server rejected the payment (bad signature, wrong
      // purchase). Don't poll for a plan that will never activate.
      final failure = result.failureOrNull;
      if (failure is ValidationFailure ||
          failure is ForbiddenFailure ||
          failure is NotFoundFailure) {
        emit(
          _fail(
            "We couldn't verify this payment. If you were charged, it "
            'will be refunded or activated shortly; contact support with '
            'payment ID $paymentId.',
          ),
        );
        return;
      }
      // Network/server error or not ACTIVE yet → fall through to polling.
    }

    await _poll(emit);
  }

  Future<void> _onExternalWallet(
    PlanPaymentExternalWallet event,
    Emitter<PlanPurchaseState> emit,
  ) => _poll(emit);

  Future<void> _onRechecked(
    PlanPurchaseStatusRechecked event,
    Emitter<PlanPurchaseState> emit,
  ) => _poll(emit);

  void _onFailed(PlanPaymentFailed event, Emitter<PlanPurchaseState> emit) {
    // Razorpay codes: 0 = network error, 2 = cancelled by the user.
    if (event.code == 2) {
      emit(
        state.copyWith(
          status: PlanPurchaseStatus.cancelled,
          message: 'Payment cancelled. You have not been charged.',
        ),
      );
      return;
    }
    if (event.code == 0) {
      emit(
        _fail(
          'Network problem during payment. Check your connection and '
          'try again.',
        ),
      );
      return;
    }
    emit(_fail(_razorpayMessage(event.message)));
  }

  /// Polls `subscriptions/me` until the purchased plan is active.
  Future<void> _poll(Emitter<PlanPurchaseState> emit) async {
    final attempt = _attempt;
    emit(state.copyWith(status: PlanPurchaseStatus.verifying));

    for (var i = 0; i < maxPollAttempts; i++) {
      if (isClosed) return;
      final sub = (await _getCurrentPlan()).valueOrNull;
      if (sub != null && attempt != null && attempt.isActivatedBy(sub)) {
        await _complete(emit, attempt);
        return;
      }
      if (i < maxPollAttempts - 1) await Future<void>.delayed(pollInterval);
    }

    if (isClosed) return;
    // The money may already be taken, so this is not shown as a failure.
    emit(
      state.copyWith(
        status: PlanPurchaseStatus.pendingActivation,
        message:
            'Payment received. Your plan is being activated; this can '
            'take a few minutes.',
      ),
    );
  }

  /// Payment is confirmed: select the bought package as the active plan
  /// (`POST subscriptions/select`), then report success.
  ///
  /// The money is already taken, so a failed select still ends in success;
  /// the page refreshes the current plan straight after.
  Future<void> _complete(
    Emitter<PlanPurchaseState> emit,
    _Attempt? attempt,
  ) async {
    _attempt = null;
    final packageId = attempt?.packageId;
    if (packageId != null && packageId.isNotEmpty) {
      await _selectPlan(packageId);
      if (isClosed) return;
    }
    emit(
      state.copyWith(
        status: PlanPurchaseStatus.success,
        message: '${state.planName ?? 'Your plan'} is now active.',
      ),
    );
  }

  PlanPurchaseState _fail(String message) =>
      state.copyWith(status: PlanPurchaseStatus.failure, message: message);

  static String _messageFor(Failure? f) {
    if (f == null) return 'Something went wrong. Please try again.';
    if (f is ConflictFailure && f.message.isEmpty) {
      return 'You already have a payment in progress for this plan.';
    }
    return f.message;
  }

  /// Razorpay sends `message` as plain text or as JSON
  /// (`{"error":{"description":"..."}}`).
  static String _razorpayMessage(String? raw) {
    const fallback = 'Payment failed. Please try again.';
    if (raw == null || raw.trim().isEmpty) return fallback;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        final err = json['error'];
        final desc = err is Map ? err['description'] : json['description'];
        if (desc is String && desc.isNotEmpty) return desc;
      }
    } catch (_) {
      // Plain text.
    }
    return raw;
  }
}

class _Attempt {
  _Attempt({
    required this.billingOptionId,
    required this.packageId,
    required this.idempotencyKey,
  }) : startedAt = DateTime.now();

  final String billingOptionId;
  final String packageId;
  final String idempotencyKey;
  final DateTime startedAt;
  String? purchaseId;
  String? subscriptionId;

  /// The server's current plan is the one this attempt bought.
  bool isActivatedBy(CurrentSubscription sub) {
    if (!sub.isActive) return false;
    final subId = subscriptionId;
    if (subId != null && sub.providerSubscriptionId == subId) return true;
    // Fallback when the provider id isn't exposed: same package, activated
    // after this attempt started (allowing for clock skew).
    final activated = sub.activatedAt;
    return sub.package.id == packageId &&
        activated != null &&
        activated.isAfter(startedAt.subtract(const Duration(minutes: 5)));
  }
}
