import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/subscription_package.dart';
import '../bloc/current_plan_bloc.dart';
import '../bloc/plan_purchase_bloc.dart';
import '../bloc/subscription_packages_bloc.dart';
import '../services/razorpay_service.dart';
import 'verifying_overlay.dart';

/// Owns the Razorpay SDK for this screen: opens checkout when the purchase
/// bloc is ready, forwards the SDK callbacks to the bloc, shows outcomes,
/// refreshes plans after success and blocks back while a payment runs.
class PurchaseCoordinator extends StatefulWidget {
  const PurchaseCoordinator({
    super.key,
    required this.type,
    required this.child,
  });

  final PackageType type;
  final Widget child;

  @override
  State<PurchaseCoordinator> createState() => _PurchaseCoordinatorState();
}

class _PurchaseCoordinatorState extends State<PurchaseCoordinator> {
  late final PlanPurchaseBloc _bloc = context.read<PlanPurchaseBloc>();
  late final RazorpayService _razorpay = RazorpayService(
    onSuccess: (r) => _add(
      PlanPaymentSucceeded(
        paymentId: r.paymentId,
        subscriptionId: r.data?['razorpay_subscription_id'] as String?,
        signature: r.signature ?? r.data?['razorpay_signature'] as String?,
      ),
    ),
    onError: (r) => _add(PlanPaymentFailed(code: r.code, message: r.message)),
    onExternalWallet: (r) => _add(PlanPaymentExternalWallet(r.walletName)),
  );

  /// SDK callbacks can arrive after the screen is gone (e.g. UPI app switch).
  void _add(PlanPurchaseEvent event) {
    if (!_bloc.isClosed) _bloc.add(event);
  }

  @override
  void dispose() {
    _razorpay.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, PlanPurchaseState state) {
    switch (state.status) {
      case PlanPurchaseStatus.checkoutReady:
        final checkout = state.checkout;
        if (checkout == null) return;
        try {
          _razorpay.open(checkout);
          _bloc.add(const PlanCheckoutOpened());
        } catch (_) {
          _bloc.add(
            const PlanPaymentFailed(message: "Couldn't open the payment page."),
          );
        }
      case PlanPurchaseStatus.freePlanSelected:
        AppSnackbar.success(title: 'Plan updated', message: state.message);
        _refreshPlans(context);
        _bloc.add(const PlanPurchaseReset());
      case PlanPurchaseStatus.success:
        AppSnackbar.success(
          title: 'Payment successful',
          message: state.message,
        );
        _refreshPlans(context);
        _bloc.add(const PlanPurchaseReset());
      case PlanPurchaseStatus.pendingActivation:
        AppSnackbar.info(
          title: 'Activation in progress',
          message: state.message,
        );
        _refreshPlans(context);
      case PlanPurchaseStatus.cancelled:
        AppSnackbar.info(title: 'Payment cancelled', message: state.message);
        _bloc.add(const PlanPurchaseReset());
      case PlanPurchaseStatus.failure:
        AppSnackbar.error(
          // No checkout means the failure was before payment (or a free plan).
          title: state.checkout == null
              ? "Couldn't update your plan"
              : 'Payment failed',
          message: state.message ?? 'Please try again.',
        );
      case PlanPurchaseStatus.idle ||
          PlanPurchaseStatus.selectingFreePlan ||
          PlanPurchaseStatus.creating ||
          PlanPurchaseStatus.inCheckout ||
          PlanPurchaseStatus.verifying:
        break;
    }
  }

  void _refreshPlans(BuildContext context) {
    context.read<CurrentPlanBloc>().add(const CurrentPlanRequested());
    context.read<SubscriptionPackagesBloc>().add(
      SubscriptionPackagesRequested(widget.type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlanPurchaseBloc, PlanPurchaseState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onState,
      buildWhen: (a, b) =>
          a.isBusy != b.isBusy ||
          (a.status == PlanPurchaseStatus.verifying) !=
              (b.status == PlanPurchaseStatus.verifying),
      builder: (context, state) => PopScope(
        canPop: !state.isBusy,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            AppSnackbar.info(
              title: 'Payment in progress',
              message: 'Please wait until the payment finishes.',
            );
          }
        },
        child: Stack(
          children: [
            widget.child,
            if (state.status == PlanPurchaseStatus.verifying)
              const VerifyingOverlay(),
          ],
        ),
      ),
    );
  }
}
