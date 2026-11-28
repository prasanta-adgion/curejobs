import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/current_subscription.dart';
import '../bloc/cancel_auto_pay_cubit.dart';
import '../bloc/current_plan_bloc.dart';
import 'auto_pay_widgets.dart';
import 'current_plan_summary.dart';
import 'plan_section.dart';

/// "Your current plan". Hidden if it fails to load, so the plans still show.
class CurrentPlanSection extends StatelessWidget {
  const CurrentPlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentPlanBloc, CurrentPlanState>(
      builder: (context, state) {
        final sub = state.subscription;
        if (sub == null) {
          if (state.status == CurrentPlanStatus.failure) {
            return const SizedBox.shrink();
          }
          return const PlanSection(
            title: 'Your current plan',
            showBand: false,
            child: SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        return PlanSection(
          title: 'Your current plan',
          showBand: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CurrentPlanSummary(subscription: sub),
              if (sub.isPaidPurchase) _AutoPay(subscription: sub),
            ],
          ),
        );
      },
    );
  }
}

/// Auto-pay row + "Turn off auto-pay?" sheet. Asks for confirmation,
/// cancels, shows the outcome and refreshes the current plan.
class _AutoPay extends StatelessWidget {
  const _AutoPay({required this.subscription});

  final CurrentSubscription subscription;

  Future<void> _onTurnOff(BuildContext context) async {
    final cubit = context.read<CancelAutoPayCubit>();
    final confirmed = await CancelAutoPaySheet.show(context, subscription);
    if (confirmed) await cubit.cancel(subscription);
  }

  void _onState(BuildContext context, CancelAutoPayState state) {
    switch (state.status) {
      case CancelAutoPayStatus.success:
        AppSnackbar.success(
          title: 'Auto-pay turned off',
          message: state.message,
        );
        context.read<CurrentPlanBloc>().add(const CurrentPlanRequested());
        context.read<CancelAutoPayCubit>().reset();
      case CancelAutoPayStatus.failure:
        AppSnackbar.error(
          title: "Couldn't turn off auto-pay",
          message: state.message ?? 'Please try again.',
        );
        context.read<CancelAutoPayCubit>().reset();
      case CancelAutoPayStatus.idle || CancelAutoPayStatus.cancelling:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CancelAutoPayCubit, CancelAutoPayState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onState,
      builder: (context, state) => AutoPaySection(
        subscription: subscription,
        busy: state.isBusy,
        onTurnOff: () => _onTurnOff(context),
      ),
    );
  }
}
