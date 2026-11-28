import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/create_purchase_usecase.dart';
import '../../domain/usecases/create_razorpay_subscription_usecase.dart';
import '../../domain/usecases/get_current_plan_usecase.dart';
import '../../domain/usecases/select_plan_usecase.dart';
import '../../domain/usecases/verify_razorpay_payment_usecase.dart';
import 'purchase_messages.dart';

part 'plan_purchase_attempt.dart';
part 'plan_purchase_event.dart';
part 'plan_purchase_state.dart';

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
    // Extra taps while a request runs are dropped.
    on<FreePlanSelected>(_onFreePlanSelected, transformer: droppable());
    on<PlanPurchaseStarted>(_onPurchaseStarted, transformer: droppable());
    on<PlanCheckoutOpened>(_onCheckoutOpened);
    on<PlanPaymentSucceeded>(_onPaymentSucceeded, transformer: droppable());
    on<PlanPaymentFailed>(_onPaymentFailed);
    on<PlanPaymentExternalWallet>(
      (_, emit) => _pollUntilActive(emit),
      transformer: droppable(),
    );
    on<PlanPurchaseStatusRechecked>(
      (_, emit) => _pollUntilActive(emit),
      transformer: droppable(),
    );
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

  /// The paid attempt in progress (null for free plans / when idle).
  _PurchaseAttempt? _attempt;

  // ───────────────────────────── FREE PLAN ─────────────────────────────

  Future<void> _onFreePlanSelected(
    FreePlanSelected event,
    Emitter<PlanPurchaseState> emit,
  ) async {
    if (state.isBusy) return;
    final package = event.package;
    emit(
      PlanPurchaseState(
        status: PlanPurchaseStatus.selectingFreePlan,
        planName: package.name,
      ),
    );

    final result = await _selectPlan(packageId: package.id);
    if (isClosed) return;

    result.fold(
      (_) => emit(
        state.copyWith(
          status: PlanPurchaseStatus.freePlanSelected,
          message: PurchaseMessages.active(package.name),
        ),
      ),
      (f) => emit(_fail(PurchaseMessages.fromFailure(f))),
    );
  }

  // ───────────────────────── PAID PLAN: steps 1–2 ─────────────────────────

  Future<void> _onPurchaseStarted(
    PlanPurchaseStarted event,
    Emitter<PlanPurchaseState> emit,
  ) async {
    if (state.isBusy) return;
    final package = event.package;
    final option = package.billingOption;
    if (package.isFree || option == null || !package.purchaseAvailable) {
      emit(_fail(PurchaseMessages.notPurchasable(package.name)));
      return;
    }

    emit(
      PlanPurchaseState(
        status: PlanPurchaseStatus.creating,
        planName: package.name,
      ),
    );
    final attempt = _attemptFor(package, option);

    // Step 1: createPurchase (skipped when retrying an existing purchase).
    if (attempt.purchaseId == null) {
      final result = await _createPurchase(
        billingOptionId: attempt.billingOptionId,
        idempotencyKey: attempt.idempotencyKey,
      );
      final purchase = result.valueOrNull;
      if (purchase == null) {
        emit(_fail(PurchaseMessages.fromFailure(result.failureOrNull)));
        return;
      }
      if (purchase.id.isEmpty) {
        emit(_fail(PurchaseMessages.couldNotStart));
        return;
      }
      attempt.purchaseId = purchase.id;
    }
    final purchaseId = attempt.purchaseId!;

    // Step 2: createRazorpaySubscription.
    final result = await _createRazorpaySubscription(purchaseId);
    final checkout = result.valueOrNull;
    if (checkout == null) {
      emit(_fail(PurchaseMessages.fromFailure(result.failureOrNull)));
      return;
    }
    if (checkout.keyId.isEmpty || checkout.subscriptionId.isEmpty) {
      emit(_fail(PurchaseMessages.couldNotStart));
      return;
    }
    attempt.subscriptionId = checkout.subscriptionId;

    // The page listens for this status and opens Razorpay.
    emit(
      state.copyWith(
        status: PlanPurchaseStatus.checkoutReady,
        checkout: _withFallbacks(checkout, purchaseId, package, option),
      ),
    );
  }

  /// Reuses the unfinished attempt for the same billing option (same
  /// idempotency key), otherwise starts a new one.
  _PurchaseAttempt _attemptFor(SubscriptionPackage package, BillingOption o) {
    final previous = _attempt;
    if (previous != null && previous.billingOptionId == o.id) return previous;
    return _attempt = _PurchaseAttempt(
      billingOptionId: o.id,
      packageId: package.id,
      idempotencyKey: _uuid.v4(),
    );
  }

  /// Fills blanks in the server's checkout with the selected plan's values
  /// so Razorpay always shows the amount the user saw.
  static RazorpayCheckout _withFallbacks(
    RazorpayCheckout c,
    String purchaseId,
    SubscriptionPackage package,
    BillingOption option,
  ) => RazorpayCheckout(
    purchaseId: c.purchaseId.isNotEmpty ? c.purchaseId : purchaseId,
    keyId: c.keyId,
    subscriptionId: c.subscriptionId,
    name: c.name.isNotEmpty ? c.name : package.name,
    description: c.description.isNotEmpty ? c.description : package.description,
    amountMinor: c.amountMinor > 0 ? c.amountMinor : option.amountMinor,
    currency: c.currency.isNotEmpty ? c.currency : option.currency,
  );

  void _onCheckoutOpened(
    PlanCheckoutOpened event,
    Emitter<PlanPurchaseState> emit,
  ) {
    if (state.status == PlanPurchaseStatus.checkoutReady) {
      emit(state.copyWith(status: PlanPurchaseStatus.inCheckout));
    }
  }

  // ───────────────────────── PAID PLAN: steps 3–4 ─────────────────────────

  Future<void> _onPaymentSucceeded(
    PlanPaymentSucceeded event,
    Emitter<PlanPurchaseState> emit,
  ) async {
    final attempt = _attempt;
    final purchaseId = attempt?.purchaseId;
    final subscriptionId =
        _nonEmpty(event.subscriptionId) ?? attempt?.subscriptionId;
    final paymentId = _nonEmpty(event.paymentId);
    final signature = _nonEmpty(event.signature);

    if (attempt == null ||
        purchaseId == null ||
        subscriptionId == null ||
        paymentId == null ||
        signature == null) {
      // Can't verify without Razorpay's payload; wait for the webhook.
      await _pollUntilActive(emit);
      return;
    }

    // Step 3: verifyRazorpayPayment.
    emit(state.copyWith(status: PlanPurchaseStatus.verifying));
    final result = await _verifyPayment(
      purchaseId: purchaseId,
      paymentId: paymentId,
      subscriptionId: subscriptionId,
      signature: signature,
    );
    if (isClosed) return;

    if (result.valueOrNull?.isActive ?? false) {
      // Step 4: selectPlan.
      await _selectPaidPlan(emit, attempt);
      return;
    }

    // A 4xx means the server rejected the payment (bad signature, wrong
    // purchase). Don't poll for a plan that will never activate.
    final failure = result.failureOrNull;
    if (failure is ValidationFailure ||
        failure is ForbiddenFailure ||
        failure is NotFoundFailure) {
      emit(_fail(PurchaseMessages.verificationRejected(paymentId)));
      return;
    }
    // Network/server error or not ACTIVE yet → wait for the webhook.
    await _pollUntilActive(emit);
  }

  /// Step 4: the payment is confirmed, so select the bought package.
  ///
  /// The money is already taken, so a failed select is reported as
  /// "activation in progress" (not failure) and the attempt is kept so a
  /// recheck retries the select.
  Future<void> _selectPaidPlan(
    Emitter<PlanPurchaseState> emit,
    _PurchaseAttempt attempt,
  ) async {
    final result = await _selectPlan(packageId: attempt.packageId);
    if (isClosed) return;

    if (result.failureOrNull != null) {
      emit(
        state.copyWith(
          status: PlanPurchaseStatus.pendingActivation,
          message: PurchaseMessages.activationPending,
        ),
      );
      return;
    }
    _attempt = null;
    emit(
      state.copyWith(
        status: PlanPurchaseStatus.success,
        message: PurchaseMessages.active(state.planName),
      ),
    );
  }

  /// Polls `subscriptions/me` until the purchased plan is active, then
  /// runs step 4.
  Future<void> _pollUntilActive(Emitter<PlanPurchaseState> emit) async {
    final attempt = _attempt;
    emit(state.copyWith(status: PlanPurchaseStatus.verifying));

    for (var i = 0; attempt != null && i < maxPollAttempts; i++) {
      if (isClosed) return;
      final sub = (await _getCurrentPlan()).valueOrNull;
      if (sub != null && attempt.isActivatedBy(sub)) {
        await _selectPaidPlan(emit, attempt);
        return;
      }
      if (i < maxPollAttempts - 1) await Future<void>.delayed(pollInterval);
    }

    if (isClosed) return;
    // The money may already be taken, so this is not shown as a failure.
    emit(
      state.copyWith(
        status: PlanPurchaseStatus.pendingActivation,
        message: PurchaseMessages.activationPending,
      ),
    );
  }

  void _onPaymentFailed(
    PlanPaymentFailed event,
    Emitter<PlanPurchaseState> emit,
  ) {
    // Razorpay codes: 0 = network error, 2 = cancelled by the user.
    switch (event.code) {
      case 2:
        emit(
          state.copyWith(
            status: PlanPurchaseStatus.cancelled,
            message: PurchaseMessages.cancelled,
          ),
        );
      case 0:
        emit(_fail(PurchaseMessages.network));
      default:
        emit(_fail(PurchaseMessages.fromRazorpay(event.message)));
    }
  }

  // ─────────────────────────────── helpers ───────────────────────────────

  PlanPurchaseState _fail(String message) =>
      state.copyWith(status: PlanPurchaseStatus.failure, message: message);

  static String? _nonEmpty(String? s) => (s == null || s.isEmpty) ? null : s;
}
