import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/subscription_package.dart';
import '../bloc/cancel_auto_pay_cubit.dart';
import '../bloc/current_plan_bloc.dart';
import '../bloc/package_request_cubit.dart';
import '../bloc/plan_purchase_bloc.dart';
import '../bloc/subscription_packages_bloc.dart';
import '../widgets/current_plan_section.dart';
import '../widgets/package_widgets.dart';
import '../widgets/packages_status_views.dart';
import '../widgets/plan_bottom_bar.dart';
import '../widgets/plan_faq_section.dart';
import '../widgets/plan_trust_section.dart';
import '../widgets/plans_app_bar.dart';
import '../widgets/purchase_coordinator.dart';
import '../widgets/request_plan_sheet.dart';
import '../widgets/review_payment_sheet.dart';

/// Lets the candidate see their current plan, compare plans and pick one.
///
/// [onContinue] overrides what the bottom button does; by default it
/// selects a free plan or starts checkout for a paid one.
class SubscriptionPackagesPage extends StatelessWidget {
  const SubscriptionPackagesPage({
    super.key,
    this.type = PackageType.candidate,
    this.onContinue,
  });

  final PackageType type;
  final void Function(BuildContext context, SubscriptionPackage package)?
  onContinue;

  static Route<void> route({
    PackageType type = PackageType.candidate,
    void Function(BuildContext, SubscriptionPackage)? onContinue,
  }) => MaterialPageRoute(
    builder: (_) =>
        SubscriptionPackagesPage(type: type, onContinue: onContinue),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<SubscriptionPackagesBloc>()
                ..add(SubscriptionPackagesRequested(type)),
        ),
        BlocProvider(
          create: (_) =>
              sl<CurrentPlanBloc>()..add(const CurrentPlanRequested()),
        ),
        BlocProvider(create: (_) => sl<PlanPurchaseBloc>()),
        BlocProvider(create: (_) => sl<CancelAutoPayCubit>()),
        BlocProvider(create: (_) => sl<PackageRequestCubit>()..load()),
      ],
      child: PurchaseCoordinator(
        type: type,
        child: BlocListener<PackageRequestCubit, PackageRequestState>(
          listenWhen: (a, b) => a.status != b.status,
          listener: (context, state) => _onRequestState(context, state),
          child: _PackagesView(type: type, onContinue: onContinue),
        ),
      ),
    );
  }

  void _onRequestState(BuildContext context, PackageRequestState state) {
    switch (state.status) {
      case PackageRequestStatus.success:
        AppSnackbar.success(title: 'Request sent', message: state.message);
        // requestAvailable flips to false on the server; reload the flags.
        context.read<SubscriptionPackagesBloc>().add(
          SubscriptionPackagesRequested(type),
        );
        context.read<PackageRequestCubit>().reset();
      case PackageRequestStatus.failure:
        AppSnackbar.error(
          title: "Couldn't send request",
          message: state.message ?? 'Please try again.',
        );
        context.read<PackageRequestCubit>().reset();
      case PackageRequestStatus.idle || PackageRequestStatus.sending:
        break;
    }
  }
}

class _PackagesView extends StatelessWidget {
  const _PackagesView({required this.type, this.onContinue});

  final PackageType type;
  final void Function(BuildContext, SubscriptionPackage)? onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerHighest,
      appBar: const PlansAppBar(),
      body: BlocBuilder<SubscriptionPackagesBloc, SubscriptionPackagesState>(
        builder: (context, state) => switch (state.status) {
          PackagesLoadStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          PackagesLoadStatus.failure => PackagesErrorView(
            message: state.failure?.message ?? "Couldn't load plans.",
            onRetry: () => context.read<SubscriptionPackagesBloc>().add(
              SubscriptionPackagesRequested(type),
            ),
          ),
          PackagesLoadStatus.success when state.packages.isEmpty =>
            const PackagesErrorView(
              message: 'No plans are available right now.',
            ),
          PackagesLoadStatus.success => RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: _PlansList(state: state),
          ),
        },
      ),
      bottomNavigationBar: _BottomBar(onContinue: _continue),
    );
  }

  Future<void> _continue(BuildContext context, SubscriptionPackage p) async {
    if (onContinue != null) {
      onContinue!(context, p);
      return;
    }

    // Never select or pay for the plan the user already has.
    final current = context.read<CurrentPlanBloc>().state.subscription;
    if (p.id == current?.package.id) {
      AppSnackbar.info(title: "You're already on ${p.name}");
      return;
    }

    // Paid users can't drop down to a free plan.
    if (current != null && !current.canSwitchTo(p)) {
      AppSnackbar.info(
        title: 'You already have ${current.package.name}',
        message:
            'Your paid plan includes everything in ${p.name}. '
            'Enjoy your premium benefits until it ends.',
      );
      return;
    }

    // Ignore taps while a payment or request is already running.
    final purchase = context.read<PlanPurchaseBloc>();
    final request = context.read<PackageRequestCubit>();
    if (purchase.state.isBusy || request.state.isBusy) return;

    if (request.state.hasPendingFor(p.id)) {
      AppSnackbar.info(
        title: 'Request already sent',
        message: 'Your request for ${p.name} is being reviewed.',
      );
      return;
    }

    switch (p.action) {
      case PlanAction.select:
        purchase.add(FreePlanSelected(p));
      case PlanAction.buy:
        // Show amount and renewal terms first, then open Razorpay.
        final confirmed = await ReviewPaymentSheet.show(context, p);
        if (confirmed && context.mounted) purchase.add(PlanPurchaseStarted(p));
      case PlanAction.request:
        final message = await RequestPlanSheet.show(context, p);
        if (message != null && context.mounted) {
          request.send(p, message: message);
        }
      case PlanAction.requestPending:
        AppSnackbar.info(
          title: 'Request already sent',
          message: 'Your request for ${p.name} is being reviewed.',
        );
      case PlanAction.unavailable:
        AppSnackbar.info(title: "${p.name} isn't available right now");
    }
  }

  Future<void> _refresh(BuildContext context) {
    final packages = context.read<SubscriptionPackagesBloc>();
    context.read<CurrentPlanBloc>().add(const CurrentPlanRequested());
    context.read<PackageRequestCubit>().load();
    packages.add(SubscriptionPackagesRequested(type));
    // Keep the spinner until the plans reload finishes.
    return packages.stream.firstWhere(
      (s) => s.status != PackagesLoadStatus.loading,
    );
  }
}

/// The scrolling content: current plan, plan cards, comparison, trust, FAQ.
class _PlansList extends StatelessWidget {
  const _PlansList({required this.state});

  final SubscriptionPackagesState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SubscriptionPackagesBloc>();
    final currentId = context.select(
      (CurrentPlanBloc b) => b.state.subscription?.package.id,
    );
    final selected = state.selected;

    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        const CurrentPlanSection(),
        PlanSection(
          title: 'Choose a plan',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final p in state.packages)
                PlanOptionCard(
                  package: p,
                  selected: p.id == state.selectedId,
                  recommended: p.id == state.recommendedId,
                  isCurrent: p.id == currentId,
                  onTap: () => bloc.add(SubscriptionPackageSelected(p.id)),
                ),
              if (selected?.requiresVerification ?? false)
                VerificationNote(
                  planName: PackageFormat.shortName(selected!.name),
                ),
            ],
          ),
        ),
        PlanSection(
          title: 'Compare plans',
          child: PackageComparisonTable(
            packages: state.packages,
            selectedId: state.selectedId,
          ),
        ),
        const PlanTrustSection(),
        const PlanFaqSection(),
      ],
    );
  }
}

/// Rebuilds the sticky bar when the selected plan or purchase state changes.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onContinue});

  final Future<void> Function(BuildContext, SubscriptionPackage) onContinue;

  @override
  Widget build(BuildContext context) {
    final selected = context.select(
      (SubscriptionPackagesBloc b) => b.state.selected,
    );
    if (selected == null) return const SizedBox.shrink();

    final current = context.select((CurrentPlanBloc b) => b.state.subscription);
    final busy =
        context.select((PlanPurchaseBloc b) => b.state.isBusy) ||
        context.select((PackageRequestCubit c) => c.state.isBusy);
    final lastRequest = context.select(
      (PackageRequestCubit c) => c.state.latestFor(selected.id),
    );

    return PlanBottomBar(
      package: selected,
      isCurrent: selected.id == current?.package.id,
      isDowngradeBlocked: !(current?.canSwitchTo(selected) ?? true),
      busy: busy,
      lastRequest: lastRequest,
      onPressed: () => onContinue(context, selected),
    );
  }
}
